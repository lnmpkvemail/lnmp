<?php

/*
|--------------------------------------------------------------------------
| Register The Artisan Commands
|--------------------------------------------------------------------------
|
| Each available Artisan command must be registered with the console so
| that it is available to be called. We'll register every command so
| the console gets access to each of the command object instances.
|
*/

Artisan::add(new TopicMarkdownConvertionCommand);
Artisan::add(new TopicMakeExcerptCommand);
Artisan::add(new UserRenameCommand);
Artisan::add(new UserMigrateGithubUsernameCommand);
Artisan::add(new ReplyMarkdownCommand);

// Backing up database
Artisan::add(new DatabaseBackupCommand);
Artisan::add(new OpcacheClearCommand);


Artisan::add(new CacheAvatarsCommand);
Artisan::add(new ContributorSyncCommand);

Artisan::resolve('InstallCommand');
