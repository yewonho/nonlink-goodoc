// // lib/dllHandler.js
// import edge from 'edge-js';
// import path from 'path';

// let dllInstance;

// const initializeDll = () => {
//   if (!dllInstance) {
//     console.log('lib진입')
//     dllInstance = edge.func({
//       assemblyFile: 'C:\\goodoc\\bin\\gdbridge.dll', // 실제 DLL 파일 경로로 변경
//       typeName: null, // 네임스페이스와 클래스 이름으로 변경
//      // methodName: 'MethodName' // 호출할 메서드 이름으로 변경
//     });
//   }
// };

// const callDllMethod = (params) => {
//   return new Promise((resolve, reject) => {
//     if (!dllInstance) {
//       initializeDll();
//     }

//     dllInstance(params, (error, result) => {
//       if (error) {
//         reject(error);
//       } else {
//         resolve(result);
//       }
//     });
//   });
// };

// export { initializeDll, callDllMethod };


const edge = require('edge-js');
const path = require('path');

const DEBUG = process.env.NODE_ENV !== 'production'; // 환경 변수를 사용하여 디버그 모드를 설정

//const dllPath = DEBUG ? path.join(__dirname, 'gdbridge.dll') : path.join(__dirname, '..', 'bin', 'gdbridge.dll');
const dllPath = 'C:\\goodoc\\bin\\gdbridge.dll'
const fallbackDllPath = 'gdbridge.dll';

const maxDataSize = 10240; // 10k
const maxDataSize4Message = 1024; // 1k

const Bridge_InitType_CallBack = 0;
const Bridge_InitType_Polling = 1;

const Bridge_Return_Error_BufferSize = 7;
const Bridge_Return_Error_NoData = 16;

const loginPrams = {'HospitalNo' : '20000351', 'Id' : 'e20000351' ,'Pass' : 'goodoc123!' };

let dllHandle = null;
let gdlLogin = null; // DLL 함수 포인터를 위한 변수


function loadDll() {
  try {
      dllHandle = edge.func({
          assemblyFile: dllPath,
          typeName: 'GoodocBridge.EdgeJSInterface', // 필요한 경우 타입 이름을 설정
          methodName: 'EdgeGdlLogin' // 필요한 경우 메서드 이름을 설정
      });
      console.log('DLL successfully loaded');

      // 특정 DLL 함수를 호출할 수 있도록 함수 포인터 초기화
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

function callGdlLogin(params, callback) {
  if (!gdlLogin) {
      callback(new Error('DLL function not initialized'));
      return;
  }
}

function gdlLogin(loginPrams, callback){
  console.log("로그인 콘솔로그")

}




module.exports = { loadDll, callGdlLogin, maxDataSize, maxDataSize4Message, Bridge_InitType_CallBack, Bridge_InitType_Polling, Bridge_Return_Error_BufferSize, Bridge_Return_Error_NoData };