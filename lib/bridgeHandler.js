
const edge = require('edge-js');
const path = require('path');

const DEBUG = process.env.NODE_ENV !== 'production'; // 환경 변수를 사용하여 디버그 모드를 설정

//const dllPath = DEBUG ? path.join(__dirname, 'gdbridge.dll') : path.join(__dirname, '..', 'bin', 'gdbridge.dll');
const dllPath = 'C:\\dev\\nonlink-goodoc\\bin\\gdbridge.dll'
const fallbackDllPath = 'gdbridge.dll';

const maxDataSize = 10240; // 10k
const maxDataSize4Message = 1024; // 1k

const Bridge_InitType_CallBack = 0;
const Bridge_InitType_Polling = 1;

const Bridge_Return_Error_BufferSize = 7;
const Bridge_Return_Error_NoData = 16;

const loginPrams = {'chartCode': '3350', 'hospitalCode':'20000351', 'initType': '0', 'callback' : '0'}
let dllHandle = null;
let gdlLogin = null; // DLL 함수 포인터를 위한 변수



function TGDL_FnCB(pjson, nlen) {
  console.log("Callback called with pjson:", pjson, "and nlen:", nlen);
  return Promise.resolve(0); // 예제 반환 값
}


function loadDll() {
  console.log('핸들러에 로드 dll시작');
  try {
      dllHandle = edge.func({
          assemblyFile: dllPath,
          typeName: 'GoodocBridge.EdgeJsInterface', // 필요한 경우 타입 이름을 설정
          methodName: 'EdgeGdlInit' // 필요한 경우 메서드 이름을 설정
      });
      console.log('DLL successfully loaded');


      return dllHandle;

      //특정 DLL 함수를 호출할 수 있도록 함수 포인터 초기화
      gdlLogin = edge.func({
          assemblyFile: dllPath,
          typeName: 'GoodocBridge.EdgeJSInterface',
          methodName: 'EdgeGdlLogin'
      });
  } catch (error) {
      console.error('Failed to load DLL:', error);
      throw error; // 에러를 다시 던져서 API 핸들러에서 잡도록 합니다.
  }
}

// function callGdlLogin(params, callback) {
//   if (!gdlLogin) {
//       callback(new Error('DLL function not initialized'));
//       return;
//   }
// }


const callDllMethod = async (payload) => {
  console.log("콜메서드 진입" + payload)
  const dll = loadDll();
  try {
    //Init 테스트용
    const result = await dll({
      ...payload,
      callback: TGDL_FnCB
    });


    //로그인 테스트용
    // const result = await dll({
    //   chartCode: 3350,
    //   userId: 20000351,
    //   password: 'goodoc123!'
    // });

    console.log('DLL method returned:', result);
    return result;
  } catch (error) {
    console.error('Error calling DLL method:', error);
    throw error;
  }
};

module.exports = { loadDll, callDllMethod,maxDataSize, maxDataSize4Message, Bridge_InitType_CallBack, Bridge_InitType_Polling, Bridge_Return_Error_BufferSize, Bridge_Return_Error_NoData };


//module.exports = { loadDll, callGdlLogin, maxDataSize, maxDataSize4Message, Bridge_InitType_CallBack, Bridge_InitType_Polling, Bridge_Return_Error_BufferSize, Bridge_Return_Error_NoData };