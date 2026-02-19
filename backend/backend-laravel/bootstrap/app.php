<?php

use App\Support\ApiResponder;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpKernel\Exception\HttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->alias([
            'role' => \App\Http\Middleware\RoleMiddleware::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        $exceptions->render(function (AuthenticationException $e) {
            return ApiResponder::error('Unauthenticated', Response::HTTP_UNAUTHORIZED);
        });

        $exceptions->render(function (AuthorizationException $e) {
            return ApiResponder::error('Forbidden', Response::HTTP_FORBIDDEN);
        });

        $exceptions->render(function (ValidationException $e) {
            return ApiResponder::error('Validation failed', Response::HTTP_UNPROCESSABLE_ENTITY, $e->errors());
        });

        $exceptions->render(function (ModelNotFoundException $e) {
            return ApiResponder::error('Not found', Response::HTTP_NOT_FOUND);
        });

        $exceptions->render(function (NotFoundHttpException $e) {
            return ApiResponder::error('Not found', Response::HTTP_NOT_FOUND);
        });

        $exceptions->render(function (HttpException $e) {
            $status = $e->getStatusCode();
            $message = $e->getMessage() ?: (Response::$statusTexts[$status] ?? 'Error');

            return ApiResponder::error($message, $status);
        });

        $exceptions->renderable(function (Throwable $e) {
            if (app()->environment('production')) {
                return ApiResponder::error('Server error', Response::HTTP_INTERNAL_SERVER_ERROR);
            }

            return null;
        });
    })->create();
