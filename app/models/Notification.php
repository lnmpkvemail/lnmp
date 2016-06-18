<?php

use Laracasts\Presenter\PresentableTrait;
use Phphub\Core\Jpush;

class Notification extends \Eloquent
{
    use PresentableTrait;
    public $presenter = 'Phphub\Presenters\NotificationPresenter';

    private static $jpush = null;

    // Don't forget to fill this array
    protected $fillable = [
            'from_user_id',
            'user_id',
            'topic_id',
            'reply_id',
            'body',
            'type'
            ];

    public function user()
    {
        return $this->belongsTo('User');
    }

    public function topic()
    {
        return $this->belongsTo('Topic');
    }

    public function fromUser()
    {
        return $this->belongsTo('User', 'from_user_id');
    }

    /**
     * Create a notification
     * @param  [type] $type     currently have 'at', 'new_reply', 'attention', 'append'
     * @param  User   $fromUser come from who
     * @param  array   $users   to who, array of users
     * @param  Topic  $topic    cuurent context
     * @param  Reply  $reply    the content
     * @return [type]           none
     */
    public static function batchNotify($type, User $fromUser, $users, Topic $topic, Reply $reply = null, $content = null)
    {
        $nowTimestamp = Carbon::now()->toDateTimeString();
        $data = [];

        foreach ($users as $toUser) {
            if ($fromUser->id == $toUser->id) {
                continue;
            }

            $data[] = [
                'from_user_id' => $fromUser->id,
                'user_id'      => $toUser->id,
                'topic_id'     => $topic->id,
                'reply_id'     => $content ?: $reply->id,
                'body'         => $content ?: $reply->body,
                'type'         => $type,
                'created_at'   => $nowTimestamp,
                'updated_at'   => $nowTimestamp
            ];

            $toUser->increment('notification_count', 1);
        }

        if (count($data)) {
            Notification::insert($data);
        }

        foreach ($data as $value) {
            self::pushNotification($value);
        }
    }

    public function scopeRecent($query)
    {
        return $query->orderBy('created_at', 'desc');
    }

    public static function notify($type, User $fromUser, User $toUser, Topic $topic, Reply $reply = null)
    {
        if ($fromUser->id == $toUser->id) {
            return;
        }

        if (Notification::isNotified($fromUser->id, $toUser->id, $topic->id, $type)) {
            return;
        }

        $nowTimestamp = Carbon::now()->toDateTimeString();


        $data = [
            'from_user_id' => $fromUser->id,
            'user_id'      => $toUser->id,
            'topic_id'     => $topic->id,
            'reply_id'     => $reply ? $reply->id : 0,
            'body'         => $reply ? $reply->body : '',
            'type'         => $type,
            'created_at'   => $nowTimestamp,
            'updated_at'   => $nowTimestamp
        ];

        $toUser->increment('notification_count', 1);

        Notification::insert([$data]);
        self::pushNotification($data);
    }

    public static function pushNotification($data)
    {
        $notification = Notification::query()
                ->with('fromUser', 'topic')
                ->where($data)
                ->first();

        if(!$notification){return;}

        $from_user_name = $notification->fromUser->name;
        $topic_title    = $notification->topic->title;
        
        $msg = $from_user_name 
                . ' • ' . $notification->present()->lableUp()
                . ' • ' . $topic_title;
        
        $push_data = array_only($data, [
            'topic_id',
            'from_user_id',
            'type',
        ]);

        if ($data['reply_id'] !== 0) {
            $push_data['reply_id']    = $data['reply_id'];
            // $push_data['replies_url'] = route('replies.web_view', $data['reply_id']);
        }

        self::jpush($notification->user_id, $msg, $push_data);
    }

    /**
     * 推送消息.
     *
     * @param $user_ids
     * @param $msg
     * @param $extras
     */
    protected static function jpush($user_ids, $msg, $extras = null)
    {
        if (!self::$jpush) {
            self::$jpush = new Jpush();
        }

        $user_ids = (array) $user_ids;
        $user_ids = array_map(function ($user_id) {
            return 'userid_'.$user_id;
        }, $user_ids);

        try {
            self::$jpush
                ->platform('all')
                ->message($msg)
                ->toAlias($user_ids)
                ->extras($extras)
                ->send();
        } catch (Exception $e) {
            // Ignore
        }
    }

    public static function isNotified($from_user_id, $user_id, $topic_id, $type)
    {
        $notifys = Notification::fromwhom($from_user_id)
                        ->toWhom($user_id)
                        ->atTopic($topic_id)
                        ->withType($type)->get();
        return $notifys->count();
    }

    public function scopeFromWhom($query, $from_user_id)
    {
        return $query->where('from_user_id', '=', $from_user_id);
    }

    public function scopeToWhom($query, $user_id)
    {
        return $query->where('user_id', '=', $user_id);
    }

    public function scopeWithType($query, $type)
    {
        return $query->where('type', '=', $type);
    }

    public function scopeAtTopic($query, $topic_id)
    {
        return $query->where('topic_id', '=', $topic_id);
    }
}
