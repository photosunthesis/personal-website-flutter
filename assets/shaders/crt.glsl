// ============================================================================
// UNIFORMS AND OUTPUTS
// ============================================================================
uniform vec2 iResolution;
uniform float iTime;
uniform sampler2D iChannel0;
out vec4 fragColor;

// ============================================================================
// CONFIGURATION PARAMETERS
// ============================================================================
vec3 iMouse = vec3(0.0, 0.0, 0.0);

float verticalJerk = 0.2;
float verticalMovement = 0.1;
float bottomStatic = 0.3;
float scanlines = 0.3;
float rgbOffset = 0.1;
float horizontalFuzz = 0.03;
float verticalTear = 0.0;
float pixelGridStrength = 0.1;

// ============================================================================
// CRT PIXEL EFFECT
// ============================================================================
vec3 crtPixelEffect(vec3 color, vec2 uv, vec2 resolution) {
    vec2 gridUv = uv * resolution;
    
    // Calculate phosphor effect color
    vec3 phosphorColor = color;
    float gridX = mod(gridUv.x, 3.0);
    
    if (gridX < 1.0) {
        phosphorColor.r *= 1.5; // Emphasize red
        phosphorColor.gb *= 0.75; // Dim green and blue
    } else if (gridX < 2.0) {
        phosphorColor.g *= 1.5; // Emphasize green
        phosphorColor.rb *= 0.75; // Dim red and blue
    } else {
        phosphorColor.b *= 1.5; // Emphasize blue
        phosphorColor.rg *= 0.75; // Dim red and green
    }
    
    // Add a subtle grid line effect
    float gridLine = sin(gridUv.y * 3.14159) * 0.1 + 0.9;
    vec3 finalColor = phosphorColor * gridLine;
    
    // Interpolate between original color and the full effect color
    return mix(color, finalColor, pixelGridStrength);
}

// ============================================================================
// NOISE FUNCTIONS
// ============================================================================
vec3 mod289(vec3 value) {
    return value - floor(value * (1.0 / 289.0)) * 289.0;
}

vec2 mod289(vec2 value) {
    return value - floor(value * (1.0 / 289.0)) * 289.0;
}

vec3 permute(vec3 value) {
    return mod289(((value * 34.0) + 1.0) * value);
}

float snoise(vec2 position) {
    const vec4 C = vec4(
        0.211324865405187,  // (3.0-sqrt(3.0))/6.0
        0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
        -0.577350269189626, // -1.0 + 2.0 * C.x
        0.024390243902439   // 1.0 / 41.0
    );
    
    // First corner
    vec2 gridIndex = floor(position + dot(position, C.yy));
    vec2 corner0 = position - gridIndex + dot(gridIndex, C.xx);
    
    // Other corners
    vec2 corner1Index = (corner0.x > corner0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    vec4 corners = corner0.xyxy + C.xxzz;
    corners.xy -= corner1Index;
    
    // Permutations
    gridIndex = mod289(gridIndex);
    vec3 permutations = permute(permute(gridIndex.y + vec3(0.0, corner1Index.y, 1.0)) + gridIndex.x + vec3(0.0, corner1Index.x, 1.0));
    
    vec3 magnitude = max(0.5 - vec3(dot(corner0, corner0), dot(corners.xy, corners.xy), dot(corners.zw, corners.zw)), 0.0);
    magnitude = magnitude * magnitude;
    magnitude = magnitude * magnitude;
    
    // Gradients: 41 points uniformly over a line, mapped onto a diamond
    vec3 gradientX = 2.0 * fract(permutations * C.www) - 1.0;
    vec3 gradientHeight = abs(gradientX) - 0.5;
    vec3 gradientOffset = floor(gradientX + 0.5);
    vec3 gradientA = gradientX - gradientOffset;
    
    // Normalize gradients implicitly by scaling m
    magnitude *= 1.79284291400159 - 0.85373472095314 * (gradientA * gradientA + gradientHeight * gradientHeight);
    
    // Compute final noise value
    vec3 gradientDot;
    gradientDot.x = gradientA.x * corner0.x + gradientHeight.x * corner0.y;
    gradientDot.yz = gradientA.yz * corners.xz + gradientHeight.yz * corners.yw;
    
    return 130.0 * dot(magnitude, gradientDot);
}

// ============================================================================
// CRT EFFECT FUNCTIONS
// ============================================================================
float calculateStaticNoise(vec2 textureCoords) {
    float staticHeight = snoise(vec2(9.0, iTime * 1.2 + 3.0)) * 0.3 + 5.0;
    float staticAmount = snoise(vec2(1.0, iTime * 1.2 - 6.0)) * 0.1 + 0.3;
    float staticStrength = snoise(vec2(-9.75, iTime * 0.6 - 3.0)) * 2.0 + 2.0;
    
    float noiseValue = snoise(vec2(
        5.0 * pow(iTime, 2.0) + pow(textureCoords.x * 7.0, 1.2),
        pow((mod(iTime, 100.0) + 100.0) * textureCoords.y * 0.3 + 3.0, staticHeight)
    ));
    
    return (1.0 - step(noiseValue, staticAmount)) * staticStrength;
}

// ============================================================================
// MAIN SHADER
// ============================================================================
void main() {
    vec2 textureCoords = gl_FragCoord.xy / iResolution.xy;
    
    // Calculate vertical distortions
    float verticalMovementEnabled = (1.0 - step(snoise(vec2(iTime * 0.2, 8.0)), 0.4)) * verticalMovement;
    float verticalJerkEffect = (1.0 - step(snoise(vec2(iTime * 1.5, 5.0)), 0.6)) * verticalTear;
    float verticalJerk2 = (1.0 - step(snoise(vec2(iTime * 5.5, 5.0)), 0.2)) * verticalJerkEffect;
    float verticalOffset = verticalJerk2 * 0.3; // Removed the other vertical movement
    float adjustedYCoord = mod(textureCoords.y + verticalOffset, 1.0);
    
    // Calculate horizontal distortions
    float fuzzOffset = snoise(vec2(iTime * 15.0, textureCoords.y * 80.0)) * 0.003;
    float largeFuzzOffset = snoise(vec2(iTime * 1.0, textureCoords.y * 25.0)) * 0.004;
    float horizontalOffset = (fuzzOffset + largeFuzzOffset) * horizontalFuzz;
    
    // Calculate static noise effect
    float staticValue = 0.0;
    for (float verticalSampleOffset = -1.0; verticalSampleOffset <= 1.0; verticalSampleOffset += 1.0) {
        float maxDistance = 5.0 / 200.0;
        float distance = verticalSampleOffset / 200.0;
        staticValue += calculateStaticNoise(vec2(textureCoords.x, textureCoords.y + distance)) * 
                      (maxDistance - abs(distance)) * 1.5;
    }
    staticValue *= bottomStatic;
    
    // Sample RGB channels with chromatic aberration
    float redChannel = texture(iChannel0, vec2(textureCoords.x + horizontalOffset - 0.01 * rgbOffset, adjustedYCoord)).r + staticValue;
    float greenChannel = texture(iChannel0, vec2(textureCoords.x + horizontalOffset, adjustedYCoord)).g + staticValue;
    float blueChannel = texture(iChannel0, vec2(textureCoords.x + horizontalOffset + 0.01 * rgbOffset, adjustedYCoord)).b + staticValue;
    
    // Apply scanlines effect
    vec3 finalColor = vec3(redChannel, greenChannel, blueChannel);
    float scanlineEffect = sin(textureCoords.y * 800.0) * 0.04 * scanlines;
    finalColor -= scanlineEffect;
    
    // Apply CRT pixel grid effect
    finalColor = crtPixelEffect(finalColor, textureCoords, iResolution);
    
    fragColor = vec4(finalColor, 1.0);
}
