
const edge = require('edge-js');
const path = require('path');
const axios = require('axios');
const { sendEvent } = require('../pages/api/sse');
const { Coming_Soon } = require('next/font/google');

const DEBUG = process.env.NODE_ENV !== 'production'; // 환경 변수를 사용하여 디버그 모드를 설정

//const dllPath = DEBUG ? path.join(__dirname, 'gdbridge.dll') : path.join(__dirname, '..', 'bin', 'gdbridge.dll');
const dllPath = 'C:\\dev\\nonlink-gd\\nonlink-goodoc\\bin\\gdbridge_x64.dll'
//const dllPath = 'C:\\goodoc\\bin\\gdbridge_x64.dll'
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



async function TGDL_FnCB(pjson, nlen) {
  console.log("콜백 펑션");
  console.log("Callback called with pjson:", pjson);
  console.log("Callback called with nlen:", nlen);
 try {
  console.log("콜백 트라이")
  const response = await axios.post('http://localhost:3000/api/post/dllCallback', {
     pjson,
     nlen
   });
  console.log("Data sent to API, response:", response.data)
  

  //sendEvent(response.data);
  
  
  return Promise.resolve(0); // 예제 반환 값
} catch (error) {
  console.log("axios 에러")
  //console.error('Error sending callback data:', error);
  return Promise.reject(error);
}
}

//pjson에 로그에 찍히는 CALLBACK 
//{"cellphone":"01000000000","regNum":"","eventId":0,"jobId":"fde434f2-b96f-4e1f-a3e0-0d048fc334f4"}
//이런거 들어오는거임. 받아서 처리하는 펑션만들면 됨. 

function loadDll(methodName) {
  console.log('핸들러에 로드 dll시작' + methodName);
  try {
      dllHandle = edge.func({
          assemblyFile: dllPath,
          typeName: 'GoodocBridge.EdgeJsInterface', // 필요한 경우 타입 이름을 설정
          methodName: methodName // 필요한 경우 메서드 이름을 설정
      });
      console.log('DLL successfully loaded');


      return dllHandle;

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
  console.log("콜메서드 진입" + payload)        //EdgeGdlSendRequest
  const dll = loadDll('EdgeGdlInit');  //EdgeGdlLogin , EdgeGdlInit, EdgeGdlDeInit, EdgeGdlSendResponse
  try {
   //Init 테스트용
    // const result = await dll({
    //   ...payload,EdgeGdlDeInit
    //   callback: TGDL_FnCB
    // });

      const result = await new Promise((resolve, reject) => {
        console.log("result Promise");
        dll({
         ...payload,
         callback: TGDL_FnCB
        //  data : {
        //   cellphone : parseInt(cellphone , 10),
        //   regNum : parseInt(regNum , 10) ,
        //   eventId :parseInt(eventId , 10),
        //   jobId : String() ,
        //  },
        //  length: parseInt(length , 10),
        //  callback: TGDL_FnCB
        }, 

        //로그인용
        // dll({hospitalCode: 20000351,
        //      userId: 'e20000351',
        //      password: 'goodoc123!'}, 
          (error, result) => {
          if (error) {
            return reject(error);
          }
          resolve(result);
        });
      });
      console.log('DLL method returned:', result);
      return result;
    
  } catch (error) {
    console.error('Error calling DLL method:', error);
    throw error;
  }
};

module.exports = { loadDll, callDllMethod, TGDL_FnCB,maxDataSize, maxDataSize4Message, Bridge_InitType_CallBack, Bridge_InitType_Polling, Bridge_Return_Error_BufferSize, Bridge_Return_Error_NoData };


//module.exports = { loadDll, callGdlLogin, maxDataSize, maxDataSize4Message, Bridge_InitType_CallBack, Bridge_InitType_Polling, Bridge_Return_Error_BufferSize, Bridge_Return_Error_NoData };