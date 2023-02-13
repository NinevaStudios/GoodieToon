half3 saturation(half3 target, half value)
{
    half luma = dot(target, half3(0.2126729, 0.7151522, 0.0721750));
    return luma.xxx + value.xxx * (target - luma.xxx);
}

half3 contrast(half3 target, half value)
{
    const half midpoint = 0.21763764082;
    return (target - midpoint) * value + midpoint;
}


float3 GetWorldScale()
{
    float x = length(float3(unity_ObjectToWorld[0].x, unity_ObjectToWorld[1].x, unity_ObjectToWorld[2].x));
    float y = length(float3(unity_ObjectToWorld[0].y, unity_ObjectToWorld[1].y, unity_ObjectToWorld[2].y));
    float z = length(float3(unity_ObjectToWorld[0].z, unity_ObjectToWorld[1].z, unity_ObjectToWorld[2].z));
    return float3(x, y, z) + 0.0001;
}

half Random(half3 pos)
{
    return frac(sin(dot(pos, half3(12.9898, 78.233, 53.539))) * 43758.5453);
}

half3x3 AngleAxis3x3(half angle, half3 axis)
{
    half c, s;
    sincos(angle, s, c);

    half t = 1 - c;
    half x = axis.x;
    half y = axis.y;
    half z = axis.z;

    return half3x3
    (
        t * x * x + c, t * x * y - s * z, t * x * z + s * y,
        t * x * y + s * z, t * y * y + c, t * y * z - s * x,
        t * x * z - s * y, t * y * z + s * x, t * z * z + c
    );
}

half3 Rotate(half3 target, half angle, half3 axis)
{
    angle = radians(angle);

    half s = sin(angle);
    half c = cos(angle);
    half _c = 1.0 - c;

    half3x3 rotation_matrix = 
    {   _c * axis.x * axis.x + c, _c * axis.x * axis.y - axis.z * s, _c * axis.z * axis.x + axis.y * s,
        _c * axis.x * axis.y + axis.z * s, _c * axis.y * axis.y + c, _c * axis.y * axis.z - axis.x * s,
        _c * axis.z * axis.x - axis.y * s, _c * axis.y * axis.z + axis.x * s, _c * axis.z * axis.z + c
    };

    return mul(rotation_matrix, target);
}
