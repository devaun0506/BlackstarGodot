shader_type canvas_item;

// Fluorescent flicker shader for harsh hospital lighting
// Creates authentic flickering fluorescent tube effect

uniform float flicker_intensity : hint_range(0.0, 1.0) = 0.3;
uniform float flicker_speed : hint_range(0.1, 10.0) = 4.0;
uniform float base_brightness : hint_range(0.5, 1.2) = 0.95;
uniform vec3 fluorescent_tint : source_color = vec3(0.96, 0.96, 0.94);
uniform bool enable_mobile_optimization : hint_default = false;

// Noise function for realistic flicker patterns
float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

float noise(float t) {
    float i = floor(t);
    float f = fract(t);
    float a = random(vec2(i, 0.0));
    float b = random(vec2(i + 1.0, 0.0));
    return mix(a, b, f);
}

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    
    // Mobile optimization: Use simpler flicker calculation
    if (enable_mobile_optimization) {
        // Simplified single-layer flicker for mobile
        float time = TIME * flicker_speed;
        float simple_flicker = noise(time) * flicker_intensity;
        float brightness = base_brightness + (simple_flicker - 0.5) * 0.5;
        brightness = clamp(brightness, 0.4, 1.1);
        
        // Apply tint without scanlines for better mobile performance
        color.rgb *= fluorescent_tint * brightness;
    } else {
        // Full desktop version with multiple layers
        float time = TIME * flicker_speed;
        
        // Multiple noise layers for realistic fluorescent behavior
        float flicker1 = noise(time) * 0.6;
        float flicker2 = noise(time * 3.0) * 0.3;
        float flicker3 = noise(time * 7.0) * 0.1;
        
        // Combine flicker patterns
        float total_flicker = flicker1 + flicker2 + flicker3;
        
        // Occasional complete flicker (like tube starting up)
        float major_flicker = step(0.98, random(vec2(floor(TIME * 2.0), 0.0))) * 0.8;
        
        // Calculate final brightness
        float brightness = base_brightness + (total_flicker - 0.5) * flicker_intensity - major_flicker;
        brightness = clamp(brightness, 0.2, 1.2);
        
        // Apply fluorescent color tint
        color.rgb *= fluorescent_tint * brightness;
        
        // Add slight scan line effect for authenticity
        float scanline = sin(UV.y * 800.0) * 0.02;
        color.rgb += vec3(scanline);
    }
    
    COLOR = color;
}