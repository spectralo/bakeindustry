shader_type canvas_item;

uniform vec4 color_a : source_color = vec4(1.0, 0.0, 0.0, 1.0); // Rouge par défaut
uniform float gradient_size : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    float alpha = UV.x * gradient_size;
    COLOR = vec4(color_a.rgb, alpha);
}