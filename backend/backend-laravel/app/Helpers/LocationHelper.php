<?php

namespace App\Helpers;

/**
 * LocationHelper
 *
 * Utility functions for location-based calculations.
 */
class LocationHelper
{
    /**
     * Calculate distance between two coordinates using Haversine formula.
     *
     * @param float $lat1 Latitude of first point (degrees)
     * @param float $lon1 Longitude of first point (degrees)
     * @param float $lat2 Latitude of second point (degrees)
     * @param float $lon2 Longitude of second point (degrees)
     * @return float Distance in kilometers
     */
    public static function haversineDistance(
        float $lat1,
        float $lon1,
        float $lat2,
        float $lon2
    ): float {
        // Earth radius in kilometers
        $earthRadius = 6371;

        // Convert degrees to radians
        $lat1Rad = deg2rad($lat1);
        $lon1Rad = deg2rad($lon1);
        $lat2Rad = deg2rad($lat2);
        $lon2Rad = deg2rad($lon2);

        // Differences
        $latDiff = $lat2Rad - $lat1Rad;
        $lonDiff = $lon2Rad - $lon1Rad;

        // Haversine formula
        $a = sin($latDiff / 2) * sin($latDiff / 2) +
             cos($lat1Rad) * cos($lat2Rad) *
             sin($lonDiff / 2) * sin($lonDiff / 2);

        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));
        $distance = $earthRadius * $c;

        return round($distance, 2);
    }

    /**
     * Check if two coordinates are within a specified radius.
     *
     * @param float $lat1 Latitude of first point
     * @param float $lon1 Longitude of first point
     * @param float $lat2 Latitude of second point
     * @param float $lon2 Longitude of second point
     * @param float $radiusKm Maximum radius in kilometers
     * @return bool True if distance is within radius
     */
    public static function isWithinRadius(
        float $lat1,
        float $lon1,
        float $lat2,
        float $lon2,
        float $radiusKm = 1.0
    ): bool {
        $distance = self::haversineDistance($lat1, $lon1, $lat2, $lon2);
        return $distance <= $radiusKm;
    }
}
