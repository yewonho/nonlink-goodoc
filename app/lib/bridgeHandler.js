// lib/dllHandler.js
import edge from 'edge-js';
import path from 'path';

let dllInstance;

const initializeDll = () => {
  if (!dllInstance) {
    console.log('lib진입')
    dllInstance = edge.func({
      assemblyFile: path.join(process.cwd(), 'C:\goodoc\bin\gdbridge.dll') // 실제 DLL 파일 경로로 변경
      //typeName: 'gdbridge' // 네임스페이스와 클래스 이름으로 변경
     // methodName: 'MethodName' // 호출할 메서드 이름으로 변경
    });
  }
};

const callDllMethod = (params) => {
  return new Promise((resolve, reject) => {
    if (!dllInstance) {
      initializeDll();
    }

    dllInstance(params, (error, result) => {
      if (error) {
        reject(error);
      } else {
        resolve(result);
      }
    });
  });
};

export { initializeDll, callDllMethod };