import { sendDataToClients } from '../sse';

export default function handler(req, res) {
  if (req.method === 'POST') {
    const { pjson, nlen } = req.body;
    console.log('Received DLL callback data:', pjson, nlen);
    
    // SSE를 통해 클라이언트로 전송
    sendDataToClients({ pjson, nlen });
    
    res.status(200).json({ message: 'Callback data received and sent to clients' });
  } else {
    res.status(405).json({ message: 'Method not allowed' });
  }
}


//import { globalDispatchAction,getGlobalState } from '../../../lib/GlobalState';


// let globalState = null;

// export function setGlobalState(state) {
//   globalState = state;
// }

// export function getGlobalState() {
//   return globalState;
//}

// export default async function handler(req, res) {
//   if (req.method === 'POST') {
//     try {
//       const { pjson, nlen } = req.body;
//       console.log('Received DLL callback data:', pjson, nlen);

//       globalDispatchAction({ type: 'SET_DATA', payload: { pjson, nlen } });

//       setTimeout(() => {
//         console.log('State after dispatch:', getGlobalState());
//       }, 100); // 상태 업데이트 후 잠시 대기 후 확인

//       //globalState = { pjson, nlen }; // 전역 상태에 데이터 저장

//       console.log('Updating global state with:',{ pjson, nlen });
//       res.status(200).json({ pjson, nlen });
//     } catch (error) {
//       console.error('Error processing request:', error);
//       res.status(500).json({ message: 'Internal Server Error' });
//     }
//   } else {
//     res.status(405).json({ message: 'Method not allowed' });
//   }
// }