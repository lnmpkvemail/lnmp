<ul class="list-group">

  @foreach ($topics as $index => $topic)
   <li class="list-group-item" >

      <a href="{{ route('topics.show', [$topic->id]) }}" title="{{{ $topic->title }}}">
        {{{ str_limit($topic->title, '100') }}}
      </a>

      <span class="meta">

        <a href="{{ route('nodes.show', [$topic->node->id]) }}" title="{{{ $topic->node->name }}}">
          {{{ $topic->node->name }}}
        </a>
        <span> • </span>
        {{ $topic->reply_count }} {{ lang('Replies') }}
        <span> • </span>
        <span class="timeago">{{ $topic->created_at }}</span>

      </span>

  </li>
  @endforeach

</ul>
