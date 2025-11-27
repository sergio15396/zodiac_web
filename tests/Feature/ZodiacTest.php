<?php

namespace Tests\Feature;

// use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ZodiacTest extends TestCase
{
    /**
     * Main page example.
     */
    public function test_the_application_returns_a_successful_response(): void
    {
        $response = $this->get('/');
        $response->assertStatus(200);
    }

    /**
     * Spanish language example.
     */
    public function test_the_application_returns_a_successful_response_in_spanish(): void
    {
        $response = $this->get('/es');
        $response->assertStatus(200);
    }

    /**
     * Pisces prediction in spanish example.
     */
    public function test_the_application_returns_a_successful_response_for_pisces_in_spanish(): void
    {
        $response = $this->get('/es/zodiac/pisces');
        $response->assertStatus(200);
    }
}
