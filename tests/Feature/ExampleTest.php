<?php

test('the application returns a successful response', function () {
    // Ensure we have an encryption key
    if (empty(config('app.key'))) {
        $this->artisan('key:generate');
    }
    
    $response = $this->get('/');
    $response->assertStatus(200);
});
