<?php

/*
|--------------------------------------------------------------------------
| Application & Route Filters
|--------------------------------------------------------------------------
|
| Below you will find the "before" and "after" events for the application
| which may be used to do any work before or after a request into your
| application. Here you may also register your custom route filters.
|
*/

App::before(function ($request) {

});


App::after(function ($request, $response) {
    //
});

/*
|--------------------------------------------------------------------------
| Authentication Filters
|--------------------------------------------------------------------------
|
| The following filters are used to verify that the user of the current
| session is logged into this application. The "basic" filter easily
| integrates HTTP Basic authentication for quick, simple checking.
|
*/

Route::filter('auth', function () {
    if (Auth::guest()) {
        if (Request::ajax())
        {
            return Response::make('Unauthorized', 401);
        }
        else
        {
            $url = Request::isMethod('get') ? URL::current() : URL::previous();
            Session::put('url.intended', $url);

            return Redirect::to('login-required');
        }
    }
});


Route::filter('auth.basic', function () {
    return Auth::basic();
});

/*
|--------------------------------------------------------------------------
| Guest Filter
|--------------------------------------------------------------------------
|
| The "guest" filter is the counterpart of the authentication filters as
| it simply checks that the current user is not logged in. A redirect
| response will be issued if they are, which you may freely change.
|
*/

Route::filter('guest', function () {
    if (Auth::check()) {
        return Redirect::to('/');
    }
});

/*
|--------------------------------------------------------------------------
| CSRF Protection Filter
|--------------------------------------------------------------------------
|
| The CSRF filter is responsible for protecting your application against
| cross-site request forgery attacks. If this special token in a user
| session does not match the one given in this request, we'll bail.
|
*/

Route::filter('csrf', function () {
    if (Session::token() != Input::get('_token')) {
        throw new Illuminate\Session\TokenMismatchException;
    }
});

Route::filter('manage_topics', function () {
    if (Auth::guest()) {
        return Redirect::guest('login-required');
    } elseif (! Entrust::can('manage_topics')) {
        // Checks the current user

        return Redirect::route('admin-required');
    }
});

Route::filter('manage_users', function () {
    if (Auth::guest()) {
        return Redirect::guest('login-required');
    } elseif (! Entrust::can('manage_users')) {
        // Checks the current user

        return Redirect::route('admin-required');
    }
});

Route::filter('check_banned_user', function () {
    // Check Banned User
    if (Auth::check() && !Route::is('user-banned') && Auth::user()->is_banned) {
        return Redirect::route('user-banned');
    }
});
