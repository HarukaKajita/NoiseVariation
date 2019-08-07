//関数内で大量に変数を定義するとGPU時間がめちゃ遅くなるのでスコープを使って書き直している部分があるので可読性が少し落ちている。ので注意。
///ret : 0.0 - <1.0
float rand(float n)
{
  return frac(sin(n) * 63452.5453123);
}

///ret : 0.0 - <1.0
float rand(float2 co)
{
  return rand(dot(co.xy, float2(24.8654, 84.657321)));
}

///ret : 0.0 - <1.0
float rand(float3 vec)
{
  return rand(dot(vec, float3(137.864342, 696.25642, 952.753978)));
}


//ret : (0, 0) - <(1, 1)
//2Dランダム
float3 rand3D(float3 vec)
{
  
  float rand1 = dot(vec, float3(6127.1, 311.7, 264.7));
  float rand2 = dot(vec, float3(269.5, 1183.3, 336.2));
  float rand3 = dot(vec, float3(301.7, 231.1, 4142.6));
  
  float3 rand = float3(rand1, rand2, rand3);
  return - 1.0 + 2.0 * frac(sin(rand) * 43758.5453123);
}


///ret : -1 - +1
float2 rand2D(float2 st)
{
  st = float2(dot(st, float2(127.1, 311.7)),
  dot(st, float2(269.5, 183.3)));
  return - 1.0 + 2.0 * frac(sin(st) * 43758.5453123);
}

///Value Noise
///ret : 0.0 - <1.0
float valNoise(float x)
{
  float i = floor(x);
  float f = frac(x);
  
  float rand_0 = rand(i);
  float rand_1 = rand(i + 1.0);
  return lerp(rand_0, rand_1, smoothstep(0.0, 1.0, f));
}

float valNoise(float2 uv)
{
  float2 i = floor(uv);
  float2 f = frac(uv);
  
  float2 sm = smoothstep(0.0, 1.0, f);
  
  //o = origin
  float rand_o = rand(i);
  float rand_x = rand(i + float2(1.0, 0.0));
  float rand_y = rand(i + float2(0.0, 1.0));
  float rand_xy = rand(i + float2(1.0, 1.0));
  
  float value_x0 = lerp(rand_o, rand_x, sm.x);
  float value_x1 = lerp(rand_y, rand_xy, sm.x);
  float value = lerp(value_x0, value_x1, sm.y);
  return value;
}

float valNoise(float3 pos)
{
  float3 i = floor(pos);
  float3 f = frac(pos);
  
  float3 sm = smoothstep(0, 1, f);
  
  float rand_o = rand(i);
  float rand_x = rand(i + float3(1.0, 0.0, 0.0));
  float rand_y = rand(i + float3(0.0, 1.0, 0.0));
  float rand_z = rand(i + float3(0.0, 0.0, 1.0));
  float rand_xy = rand(i + float3(1.0, 1.0, 0.0));
  float rand_xz = rand(i + float3(1.0, 0.0, 1.0));
  float rand_yz = rand(i + float3(0.0, 1.0, 1.0));
  float rand_xyz = rand(i + float3(1.0, 1.0, 1.0));
  
  //底面
  float value_x0 = lerp(rand_o, rand_x, sm.x);
  float value_x1 = lerp(rand_z, rand_xz, sm.x);
  float noiseXZ0 = lerp(value_x0, value_x1, sm.z);
  
  //天井
  float value_x2 = lerp(rand_y, rand_xy, sm.x);
  float value_x3 = lerp(rand_yz, rand_xyz, sm.x);
  float noiseXZ1 = lerp(value_x2, value_x3, sm.z);
  
  float noise = lerp(noiseXZ0, noiseXZ1, sm.y);
  return noise;
}

//Perline Noise

float pNoise(float pos)
{
  return pNoise(float2(pos, 0));
}

float pNoise(float2 pos)
{
  float2 i_o = floor(pos);
  float2 f = frac(pos);
  
  float2 sm = smoothstep(0, 1, f);
  
  float dot_o = 0;
  float dot_x = 0;
  float dot_y = 0;
  float dot_xy = 0;
  {
    float2 i_x = i_o + float2(1, 0);
    float2 i_y = i_o + float2(0, 1);
    float2 i_xy = i_o + float2(1, 1);
    float2 rand_o = rand2D(i_o);
    float2 rand_x = rand2D(i_x);
    float2 rand_y = rand2D(i_y);
    float2 rand_xy = rand2D(i_xy);
    
    float2 toPos_o = pos - i_o;
    float2 toPos_x = pos - i_x;
    float2 toPos_y = pos - i_y;
    float2 toPos_xy = pos - i_xy;
    
    dot_o = dot(rand_o, toPos_o) * 0.5 + 0.5;
    dot_x = dot(rand_x, toPos_x) * 0.5 + 0.5;
    dot_y = dot(rand_y, toPos_y) * 0.5 + 0.5;
    dot_xy = dot(rand_xy, toPos_xy) * 0.5 + 0.5;
  }
  
  float value1 = lerp(dot_o, dot_x, sm.x);
  float value2 = lerp(dot_y, dot_xy, sm.x);
  float value3 = lerp(0, value2 - value1, sm.y);
  return value1 + value3;
}

float pNoise(float3 pos)
{
  float3 i_o = floor(pos);
  float3 f = frac(pos);
  
  float3 sm = smoothstep(0, 1, f);
  
  float dot_o = 0;
  float dot_x = 0;
  float dot_y = 0;
  float dot_z = 0;
  float dot_xy = 0;
  float dot_xz = 0;
  float dot_yz = 0;
  float dot_xyz = 0;
  {
    float3 i_x = i_o + float3(1, 0, 0);
    float3 i_y = i_o + float3(0, 1, 0);
    float3 i_z = i_o + float3(0, 0, 1);
    float3 i_xy = i_o + float3(1, 1, 0);
    float3 i_xz = i_o + float3(1, 0, 1);
    float3 i_yz = i_o + float3(0, 1, 1);
    float3 i_xyz = i_o + float3(1, 1, 1);
    float3 rand_o = rand3D(i_o);
    float3 rand_x = rand3D(i_x);
    float3 rand_y = rand3D(i_y);
    float3 rand_z = rand3D(i_z);
    float3 rand_xy = rand3D(i_xy);
    float3 rand_xz = rand3D(i_xz);
    float3 rand_yz = rand3D(i_yz);
    float3 rand_xyz = rand3D(i_xyz);
    
    float3 toPos_o = pos - i_o;
    float3 toPos_x = pos - i_x;
    float3 toPos_y = pos - i_y;
    float3 toPos_z = pos - i_z;
    float3 toPos_xy = pos - i_xy;
    float3 toPos_xz = pos - i_xz;
    float3 toPos_yz = pos - i_yz;
    float3 toPos_xyz = pos - i_xyz;
    
    dot_o = dot(rand_o, toPos_o) * 0.5 + 0.5;
    dot_x = dot(rand_x, toPos_x) * 0.5 + 0.5;
    dot_y = dot(rand_y, toPos_y) * 0.5 + 0.5;
    dot_z = dot(rand_z, toPos_z) * 0.5 + 0.5;
    dot_xy = dot(rand_xy, toPos_xy) * 0.5 + 0.5;
    dot_xz = dot(rand_xz, toPos_xz) * 0.5 + 0.5;
    dot_yz = dot(rand_yz, toPos_yz) * 0.5 + 0.5;
    dot_xyz = dot(rand_xyz, toPos_xyz) * 0.5 + 0.5;
  }
  
  //底面
  float value_x0 = lerp(dot_o, dot_x, sm.x);
  float value_x1 = lerp(dot_z, dot_xz, sm.x);
  float noiseXZ0 = lerp(value_x0, value_x1, sm.z);
  
  //天井
  float value_x2 = lerp(dot_y, dot_xy, sm.x);
  float value_x3 = lerp(dot_yz, dot_xyz, sm.x);
  float noiseXZ1 = lerp(value_x2, value_x3, sm.z);
  
  return lerp(noiseXZ0, noiseXZ1, sm.y);//yでブレンド
}

//Cellular Noise
float cNoise(float2 pos)
{
  float2 i_o = floor(pos);
  
  float nearDist = 100000000;
  
  for (int i = -1; i <= 1; i ++)
  {
    for (int j = -1; j <= 1; j ++)
    {
      float2 base_pos = i_o + float2(i, j);
      float2 rand_pos = base_pos + rand2D(base_pos) * 0.5 + 0.5;
      float dist = length(rand_pos - pos);
      if (dist < nearDist) nearDist = dist;
    }
  }
  
  return nearDist / 1.41421356;
}

float3 getNearCellPos(float3 pos)
{
  float3 i_o = floor(pos);
  
  float nearDist = 100000000;
  float3 nearPos = 0;
  
  for (int i = -1; i <= 1; i ++)
  {
    
    for (int j = -1; j <= 1; j ++)
    {
      
      for (int k = -1; k <= 1; k ++)
      {
        float3 base_pos = i_o + float3(i, j, k);
        float3 rand_pos = base_pos + rand3D(base_pos) * 0.5 + 0.5;
        float dist = length(rand_pos - pos);
        if(dist < nearDist)
        {
          nearDist = dist;
          nearPos = rand_pos;
        }
      }
    }
  }
  
  return nearPos;
}

float cNoise(float3 pos)
{
  float3 i_o = floor(pos);
  
  float nearDist = 100000000;
  
  for (int i = -1; i <= 1; i ++)
  {
    for (int j = -1; j <= 1; j ++)
    {
      for (int k = -1; k <= 1; k ++)
      {
        float3 base_pos = i_o + float3(i, j, k);
        float3 rand_pos = base_pos + rand3D(base_pos) * 0.5 + 0.5;
        float dist = length(rand_pos - pos);
        if(dist < nearDist) nearDist = dist;
      }
    }
  }
  return nearDist;
  //return nearDist / 1.7320508;
}

//一次ノイズ(2D)
float getNoise(float2 pos, float scale, int type)
{
  pos *= scale;
  float value = 0;
  if (type == 0)
  {
    value = valNoise(pos);
  }
  else if(type == 1)
  {
    value = pNoise(pos);
  }
  else if(type == 2)
  {
    value = cNoise(pos);
  }
  return value;
}

//一次ノイズ(3D)
float getNoise(float3 pos, float scale, int type)
{
  pos *= scale;
  float value = 0;
  if (type == 0)
  {
    value = valNoise(pos);
  }
  else if(type == 1)
  {
    value = pNoise(pos);
  }
  else if(type == 2)
  {
    value = cNoise(pos);
  }
  return value;
}

//一次ノイズ(2Dベクトル)
float2 getNoise2D(float2 pos, float scale, int type)
{
  pos *= scale;
  float2 value = 0;
  if (type == 0)
  {
    value.x = valNoise(pos);
    value.y = valNoise(pos+10);
  }
  else if(type == 1)
  {
    value.x = pNoise(pos);
    value.y = pNoise(pos+10);
  }
  else if(type == 2)
  {
    value.x = cNoise(pos);
    value.y = cNoise(pos+10);
  }
  return value;
}

//一次ノイズ(3Dベクトル)
float3 getNoise3D(float3 pos, float scale, int type)
{
  pos *= scale;
  float3 value = 0;
  if (type == 0)
  {
    value.x = valNoise(pos);
    value.y = valNoise(pos+10);
    value.z = valNoise(pos+100);
  }
  else if(type == 1)
  {
    value.x = pNoise(pos);
    value.y = pNoise(pos+10);
    value.z = pNoise(pos+100);
  }
  else if(type == 2)
  {
    value.x = cNoise(pos);
    value.y = cNoise(pos+10);
    value.z = cNoise(pos+100);
  }
  return normalize(value*2-1);
}

///Curl Noise
//これおかしいのでどうしようかな
float curlNoise(float2 pos, float scale, int type)
{
  const float epsilon = 0.00001;
  float2 n_px = getNoise2D(pos*scale + float2(epsilon, 0), 1 ,type);
  float2 n_mx = getNoise2D(pos*scale - float2(epsilon, 0), 1 ,type);
  float2 n_py = getNoise2D(pos*scale + float2(0, epsilon), 1 ,type);
  float2 n_my = getNoise2D(pos*scale - float2(0, epsilon), 1 ,type);
  
  float z = n_mx.y - n_px.y - n_my.x + n_py.x;
  //近傍を加減算してるから0に近いはず。
  //3Dのカールノイズならnormalizeするけど、2D空間でカールノイズを考えるとZ軸の回転量しか算出されないのでスカラーになる。
  //無理やりnormalizeを考えると1or-1を返す関数になってしまう。
  //上手い事連続的な値を返すようにするには何か工夫が必要そう。
  return z;
}

float3 curlNoise(float3 pos, float scale, int type)
{
  const float epsilon = 0.001;
  
  float3 n_px = getNoise3D(pos*scale + float3(epsilon, 0, 0), 1, type);
  float3 n_mx = getNoise3D(pos*scale - float3(epsilon, 0, 0), 1, type);
  float3 n_py = getNoise3D(pos*scale + float3(0, epsilon, 0), 1, type);
  float3 n_my = getNoise3D(pos*scale - float3(0, epsilon, 0), 1, type);
  float3 n_pz = getNoise3D(pos*scale + float3(0, 0, epsilon), 1, type);
  float3 n_mz = getNoise3D(pos*scale - float3(0, 0, epsilon), 1, type);
  
  float x = n_my.z - n_py.z - n_mz.y + n_pz.y;
  float y = n_px.z - n_mx.z - n_pz.x + n_mz.x;
  float z = n_mx.y - n_px.y - n_my.x + n_py.x;

  float3 ret = normalize(float3(x, y, z));
  return ret;
}

///fBM
float fbm(float2 uv, float scale, int type)
{
  uv *= scale;
  float gain = 0.5;
  float freqIncrease = 2.0;
  float octaves = 5;
  
  //default value
  float amp = 0.5;
  float fre = 1.0;
  
  float maxValue = 0;
  float ret = 0.0;//return
  
  for (int i = 0; i < octaves; i ++)
  {
    //任意のノイズを使う
    ret += getNoise(uv, fre, type) * amp;
    fre *= freqIncrease;
    maxValue += amp;
    amp *= gain;
  }
  return ret / maxValue;
}

float fbm(float3 pos, float scale, int type1st)
{
  pos *= scale;
  float gain = 0.5;
  float freqIncrease = 2.0;
  float octaves = 5;
  
  //default value
  float amp = 0.5;
  float fre = 1.0;
  
  float maxValue = 0;
  float ret = 0.0;//return
  
  for (int i = 0; i < octaves; i ++)
  {
    //任意のノイズを使う
    ret += getNoise(pos, fre, type1st) * amp;
    fre *= freqIncrease;
    maxValue += amp;
    amp *= gain;
  }
  return ret / maxValue;
}

///Gradient
float2 gradientNoise(float2 pos, float scale, int type1st)
{
  const float epsilon = 0.0001;
  float center = 0;
  float noiseX = 0;
  float noiseY = 0;
  //一次ノイズの勾配
  center = getNoise(pos*scale, 1, type1st);
  noiseX = getNoise(pos*scale - float2(epsilon, 0), 1, type1st);
  noiseY = getNoise(pos*scale - float2(0, epsilon), 1, type1st);
  
  return normalize(float2(center - noiseX, center - noiseY));
}

float3 gradientNoise(float3 pos, float scale, int type1st, float epsilon = 0.001)
{
  float center = 0;
  float noiseX = 0;
  float noiseY = 0;
  float noiseZ = 0;
  //一次ノイズの勾配
  center = getNoise(pos*scale, 1, type1st);
  noiseX = getNoise(pos*scale - float3(epsilon, 0, 0), 1, type1st);
  noiseY = getNoise(pos*scale - float3(0, epsilon, 0), 1, type1st);
  noiseZ = getNoise(pos*scale - float3(0, 0, epsilon), 1, type1st);  
  
  return normalize(float3(center - noiseX, center - noiseY, center - noiseZ));
}

float divergenceNoise(float2 pos, float scale, int type1st, float amp){
  const float epsilon = 0.01;
  float2 center = 0;
  float noiseX = 0;
  float noiseY = 0;
  //一次ノイズの発散
  center = getNoise2D(pos*scale, 1, type1st);
  noiseX = getNoise2D(pos*scale - float2(epsilon, 0), 1, type1st).x;
  noiseY = getNoise2D(pos*scale - float2(0, epsilon), 1, type1st).y;
  
  //適当にabsして値を盛る。数学的意味は無視。
  return float(abs(center.x - noiseX) + abs(center.y - noiseY))*amp;
}

float divergenceNoise(float3 pos, float scale, int type1st, float amp){
  const float epsilon = 0.01;
  float3 center = 0;
  float noiseX = 0;
  float noiseY = 0;
  float noiseZ = 0;
  //一次ノイズの発散
  center = getNoise3D(pos*scale, 1, type1st);
  noiseX = getNoise3D(pos*scale - float3(epsilon, 0, 0), 1, type1st).x;
  noiseY = getNoise3D(pos*scale - float3(0, epsilon, 0), 1, type1st).y;
  noiseZ = getNoise3D(pos*scale - float3(0, 0, epsilon), 1, type1st).z;
  
  //適当にabsして値を盛る。数学的意味は無視。
  return float(abs(center.x - noiseX) + abs(center.y - noiseY) + abs(center.z - noiseZ))*amp;
}

float laplacian (float2 pos, float scale, int type1st, float amp){
  const float epsilon = 0.01;
  float2 center = 0;
  float noiseX = 0;
  float noiseY = 0;
  //一次ノイズの発散
  center = gradientNoise(pos*scale, 1, type1st);
  noiseX = gradientNoise(pos*scale - float2(epsilon, 0), 1, type1st).x;
  noiseY = gradientNoise(pos*scale - float2(0, epsilon), 1, type1st).y;
  
  //適当にabsして値を盛る。数学的意味は無視。
  return float(abs(center.x - noiseX) + abs(center.y - noiseY))*amp;
}

float laplacian (float3 pos, float scale, int type1st, float amp){
  const float epsilon = 0.01;
  float3 center = 0;
  float noiseX = 0;
  float noiseY = 0;
  float noiseZ = 0;
  float noiseX1 = 0;
  float noiseY1 = 0;
  float noiseZ1 = 0;
  //一次ノイズの発散
  //不連続性が目立つ問題は勾配のepsilonを調整し解消できたので0.3を引数に渡している
  center = gradientNoise(pos*scale, 1, type1st, 0.3)*0.5+0.5;
  noiseX1 = gradientNoise(pos*scale + float3(epsilon, 0, 0), 1, type1st, 0.3).x*0.5+0.5;
  noiseY1 = gradientNoise(pos*scale + float3(0, epsilon, 0), 1, type1st, 0.3).y*0.5+0.5;
  noiseZ1 = gradientNoise(pos*scale + float3(0, 0, epsilon), 1, type1st, 0.3).z*0.5+0.5;
  noiseX = gradientNoise(pos*scale - float3(epsilon, 0, 0), 1, type1st, 0.3).x*0.5+0.5;
  noiseY = gradientNoise(pos*scale - float3(0, epsilon, 0), 1, type1st, 0.3).y*0.5+0.5;
  noiseZ = gradientNoise(pos*scale - float3(0, 0, epsilon), 1, type1st, 0.3).z*0.5+0.5;
  
  //適当にabsして値を盛る。数学的意味は無視。
  return float(abs(center.x - noiseX) + abs(center.y - noiseY) + abs(center.z - noiseZ))*amp;
  //return float((center.x - noiseX) + (center.y - noiseY) + (center.z - noiseZ))*amp;
  //return float(abs(noiseX1 - noiseX) + abs(noiseY1 - noiseY) + abs(noiseZ1 - noiseZ))*amp;
  //return noiseX1;
  //return float((noiseX1 - noiseX) + (noiseY1 - noiseY) + (noiseZ1 - noiseZ))*amp;
  //return abs(center.x - noiseX)*amp;
}

//二次ノイズ(3D)
//fbm, curl, gradient, divergence, laplacian
float2 get2ndNoise(float2 pos, float scale, int type2nd, int type1st, float divConst = 20){
  float2 value = 0;
  if(type2nd == 0){
    value = (float2)fbm(pos, scale, type1st);
  } else if(type2nd == 1){
    value = (float2)curlNoise(pos, scale, type1st);
  } else if(type2nd == 2){
    value = gradientNoise(pos, scale, type1st).xy;
  } else if(type2nd == 3){
    value = (float2)divergenceNoise(pos, scale, type1st, divConst);
  }
  return value;
}

float3 get2ndNoise(float3 pos, float scale, int type2nd, int type1st, float divConst = 20){
  float3 value = 0;
  if(type2nd == 0){
    value = (float3)fbm(pos, scale, type1st);
  } else if(type2nd == 1){
    value = curlNoise(pos, scale, type1st);
  } else if(type2nd == 2){
    value = gradientNoise(pos, scale, type1st);
  } else if(type2nd == 3){
    value = (float3)divergenceNoise(pos, scale, type1st, divConst);
  } else if (type2nd == 4){
    value = (float3)laplacian(pos, scale, type1st, divConst);
  }
  return value;
}

////////////////////再帰関数は定義できないので関数を三次ノイズ用に定義
///Curl Noise
//これおかしいのでどうしようかな
float curlNoise_as3rdNoise(float2 pos, float scale, int type2nd, int type1st, float divConst = 20)
{
  const float epsilon = 0.00001;
  float2 n_px = get2ndNoise(pos*scale + float2(epsilon, 0), 1, type2nd, type1st, divConst);
  float2 n_mx = get2ndNoise(pos*scale - float2(epsilon, 0), 1, type2nd, type1st, divConst);
  float2 n_py = get2ndNoise(pos*scale + float2(0, epsilon), 1, type2nd, type1st, divConst);
  float2 n_my = get2ndNoise(pos*scale - float2(0, epsilon), 1, type2nd, type1st, divConst);
  
  float z = n_mx.y - n_px.y - n_my.x + n_py.x;
  //近傍を加減算してるから0に近いはず。
  //3Dのカールノイズならnormalizeするけど、2D空間でカールノイズを考えるとZ軸の回転量しか算出されないのでスカラーになる。
  //無理やりnormalizeを考えると1or-1を返す関数になってしまう。
  //上手い事連続的な値を返すようにするには何か工夫が必要そう。
  return z;
}

float3 curlNoise_as3rdNoise(float3 pos, float scale, int type2nd, int type1st, float divConst = 20)
{
  const float epsilon = 0.00001;
  
  float3 n_px = get2ndNoise(pos*scale + float3(epsilon, 0, 0), 1, type2nd, type1st, divConst);
  float3 n_mx = get2ndNoise(pos*scale - float3(epsilon, 0, 0), 1, type2nd, type1st, divConst);
  float3 n_py = get2ndNoise(pos*scale + float3(0, epsilon, 0), 1, type2nd, type1st, divConst);
  float3 n_my = get2ndNoise(pos*scale - float3(0, epsilon, 0), 1, type2nd, type1st, divConst);
  float3 n_pz = get2ndNoise(pos*scale + float3(0, 0, epsilon), 1, type2nd, type1st, divConst);
  float3 n_mz = get2ndNoise(pos*scale - float3(0, 0, epsilon), 1, type2nd, type1st, divConst);
  
  float x = n_my.z - n_py.z - n_mz.y + n_pz.y;
  float y = n_px.z - n_mx.z - n_pz.x + n_mz.x;
  float z = n_mx.y - n_px.y - n_my.x + n_py.x;

  float3 ret = normalize(float3(x, y, z));
  return ret;
}

///fBM
float fbm_as3rdNoise(float2 uv, float scale, int type2nd, int type1st, float divConst = 20)
{
  uv *= scale;
  float gain = 0.5;
  float freqIncrease = 2.0;
  float octaves = 5;
  
  //default value
  float amp = 0.5;
  float fre = 1.0;
  
  float ret = 0.0;//return
  
  for (int i = 0; i < octaves; i ++)
  {
    //任意のノイズを使う
    ret += get2ndNoise(uv, fre, type2nd, type1st, divConst) * amp;
    fre *= freqIncrease;
    amp *= gain;
  }
  return ret;
}

float fbm_as3rdNoise(float3 pos, float scale, int type2nd, int type1st, float divConst = 20)
{
  pos *= scale;
  float gain = 0.5;
  float freqIncrease = 2.0;
  float octaves = 5;
  
  //default value
  float amp = 0.5;
  float fre = 1.0;
  
  float maxValue = 0;
  float ret = 0.0;//return
  
  for (int i = 0; i < octaves; i ++)
  {
    //任意のノイズを使う
    ret += get2ndNoise(pos, fre, type2nd, type1st, divConst) * amp;
    fre *= freqIncrease;
    maxValue += amp;
    amp *= gain;
  }
  return ret / maxValue;
}

///Gradient
float2 gradientNoise_as3rdNoise(float2 pos, float scale, int type1st, int type2nd = 0, float divConst = 20)
{
  const float epsilon = 0.0001;
  float center = 0;
  float noiseX = 0;
  float noiseY = 0;
  
  //二次ノイズの勾配
  center = get2ndNoise(pos*scale, 1, type2nd, type1st, divConst);
  noiseX = get2ndNoise(pos*scale - float2(epsilon, 0), 1, type2nd, type1st, divConst);
  noiseY = get2ndNoise(pos*scale - float2(0, epsilon), 1, type2nd, type1st, divConst);
  
  return normalize(float2(center - noiseX, center - noiseY));
}

float3 gradientNoise_as3rdNoise(float3 pos, float scale, int type1st, int type2nd = 0, float divConst = 20)
{
  const float epsilon = 0.0001;
  float center = 0;
  float noiseX = 0;
  float noiseY = 0;
  float noiseZ = 0;
  
  //二次ノイズの勾配
  center = get2ndNoise(pos*scale, 1, type2nd, type1st, divConst);
  noiseX = get2ndNoise(pos*scale - float3(epsilon, 0, 0), 1, type2nd, type1st, divConst);
  noiseY = get2ndNoise(pos*scale - float3(0, epsilon, 0), 1, type2nd, type1st, divConst);
  noiseZ = get2ndNoise(pos*scale - float3(0, 0, epsilon), 1, type2nd, type1st, divConst);
  
  return normalize(float3(center - noiseX, center - noiseY, center - noiseZ));
}

float divergenceNoise_as3rdNoise(float2 pos, float scale, int type1st, float amp, int type2nd = 0, float divConst = 20){
  const float epsilon = 0.01;
  float2 center = 0;
  float noiseX = 0;
  float noiseY = 0;
  
  //二次ノイズの発散
  center = get2ndNoise(pos*scale, 1, type2nd, type1st, divConst);
  noiseX = get2ndNoise(pos*scale - float2(epsilon, 0), 1, type2nd, type1st, divConst).x;
  noiseY = get2ndNoise(pos*scale - float2(0, epsilon), 1, type2nd, type1st, divConst).y;
  
  //適当にabsして値を盛る。数学的意味は無視。
  return float(abs(center.x - noiseX) + abs(center.y - noiseY))*amp;
}

float divergenceNoise_as3rdNoise(float3 pos, float scale, int type1st, float amp, int type2nd = 0, float divConst = 20){
  const float epsilon = 0.01;
  float3 center = 0;
  float noiseX = 0;
  float noiseY = 0;
  float noiseZ = 0;
  
  //二次ノイズの発散
  center = get2ndNoise(pos*scale, 1, type2nd, type1st, divConst);
  noiseX = get2ndNoise(pos*scale - float3(epsilon, 0, 0), 1, type2nd, type1st, divConst).x;
  noiseY = get2ndNoise(pos*scale - float3(0, epsilon, 0), 1, type2nd, type1st, divConst).y;
  noiseZ = get2ndNoise(pos*scale - float3(0, 0, epsilon), 1,  type2nd, type1st, divConst).z;
  
  //適当にabsして値を盛る。数学的意味は無視。
  return float(abs(center.x - noiseX) + abs(center.y - noiseY) + abs(center.z - noiseZ))*amp;
}

float hogeNoise(float3 pos, float scale, int type, float amp, float epsilon = 1){
  float center = getNoise(pos, scale, type);
  float noise1 = getNoise(pos*scale - float3(epsilon, 0, 0), 1, type);
  float noise3 = getNoise(pos*scale - float3(0, epsilon, 0), 1, type);
  float noise5 = getNoise(pos*scale - float3(0, 0, epsilon), 1, type);
  return float(abs(center - noise1) + abs(center - noise3) + abs(center - noise5))*amp;
}