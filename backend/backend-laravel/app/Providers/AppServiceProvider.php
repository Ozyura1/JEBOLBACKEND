<?php

namespace App\Providers;

use App\Models\PerkawinanRequest;
use App\Policies\PerkawinanRequestPolicy;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Gate::policy(PerkawinanRequest::class, PerkawinanRequestPolicy::class);

        // Register API routes from routes/api.php (Project uses routes/api.php for API endpoints)
        if (file_exists(base_path('routes/api.php'))) {
            \Illuminate\Support\Facades\Route::middleware('api')
                ->prefix('api')
                ->group(base_path('routes/api.php'));
        }

        // Rate limiter for login to mitigate brute-force
        RateLimiter::for('login', function (Request $request) {
            return Limit::perMinute(5)->by($request->ip());
        });
    }
}
