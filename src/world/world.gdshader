shader_type spatial;

void fragment() {
	vec2 grid_uv = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xz;

	vec2 grid = abs(fract(grid_uv - 0.5) - 0.5) / fwidth(grid_uv);
	float line = min(grid.x, grid.y);

	vec3 base_color = vec3(0.12);
	vec3 grid_color = vec3(0.45);

	ALBEDO = mix(grid_color, base_color, smoothstep(0.0, 1.0, line));
}