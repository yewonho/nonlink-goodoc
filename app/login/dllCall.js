'use client'

//일단 됨.

import { useEffect, useState } from 'react';
//import { useGlobalState , getGlobalState } from '../../lib/GlobalState';
//import { getGlobalState } from '../../pages/api/post/dllCallback';

export default function DllCall() {
    const [data, setData] = useState(null);
    const [error, setError] = useState(null);
  //  const state = useGlobalState();
  const [connectionStatus, setConnectionStatus] = useState('Disconnected');
  const [messages, setMessages] = useState([]);
  const [clientId, setClientId] = useState(null);


  useEffect(() => {
    let eventSource;

    const connectSSE = () => {
      console.log('Connecting to SSE...');
      eventSource = new EventSource('/api/sse');

      eventSource.onopen = (event) => {
        console.log('SSE connection opened');
      };

      eventSource.onmessage = (event) => {
        console.log('Received message:', event.data);
        const data = JSON.parse(event.data);
        if (data.type === 'connection' && data.status === 'opened') {
          setClientId(data.clientId);
          console.log(`Connected with client ID: ${data.clientId}`);
        } else {
          setMessages((prevMessages) => [...prevMessages, data]);
        }
      };

      eventSource.onerror = (error) => {
        console.error('SSE error:', error);
        eventSource.close();
        setTimeout(connectSSE, 5000); // 5초 후 재연결 시도
      };
    };

    connectSSE();

    return () => {
      console.log('Closing SSE connection');
      if (eventSource) {
        eventSource.close();
      }
    };
  }, []);

  return (
    <div>
      <h1>SSE Client (ID: {clientId})</h1>
      {messages.map((message, index) => (
        <div key={index}>{JSON.stringify(message)}</div>
      ))}
    </div>
  );
}


    // 전역변수
    // useEffect(() => {
    //     console.log('useEffect triggered');
    
    //     const interval = setInterval(() => {
    //       //  console.log("인터벌")
    //       const globalData = getGlobalState();
    //     //  console.log('글로벌데이터',globalData)
    //       if (globalData && globalData.data) {
    //         console.log('State data updated: ', globalData);
    //         setData(globalData.data);
    //       }
    //     }, 1000); // 1초마다 전역 상태 확인
    
    //     return () => clearInterval(interval); // 컴포넌트 언마운트 시 인터벌 제거
    //   }, []);
    
    //   if (!data) {
    //     return <div>Loading...</div>;
    //   }
    
    //   return (
    //     <div>
    //       <h1>DLL Callback Data</h1>
    //       <pre>{JSON.stringify(data, null, 2)}</pre>
    //     </div>
    //   );
    // }
    
//     useEffect(() => { 
//       async function fetchData() {
//         console.log("Fetching data...");
//         try {
//             const response = await fetch('/api/post/dllCallback', {
//               method: 'POST', // POST 요청으로 변경
//               headers: {
//                   'Content-Type': 'application/json'
//               },
//               body: JSON.stringify({
//                   pjson : {
//                     cellphone : 0,
//                     regNum : "",
//                     eventId :0,
//                     jobId : ""
//                    }
//               })
//           });
//           console.log("Fetch response received",response );


//             if (!response.ok) {
//                 throw new Error('Network response was not ok', "Network response was not ok:", response.status, response.statusText);
//             }

//             const result = await response.json();
//             console.log("리스펀스 데이터" +  JSON.stringify(result, null, 2))
//             setData(result);
//         } catch (error) {
//           console.log("Error in fetchData:", error);  
//           setError(error);
//         }
//     }

//     fetchData();
// }, []);

// if (error) {
//     return <div>dllCalljs Error: {error.message}</div>;
// }

// if (!data) {
//     return <div>Loading...</div>;
// }

// return (
//     <div>
//         <h1>DLL Callback Data</h1>
//         <pre>{JSON.stringify(data, null, 2)}</pre>
//     </div>
// );

//}




//sse

// useEffect(() => {
//     let eventSource;

//         const connectSSE = () => {
//             console.log("Connecting to SSE...");
//             setConnectionStatus('Connecting');

//             eventSource = new EventSource('/api/sse');
          
//             eventSource.onopen = () => {
//               console.log("SSE connection opened");
//               setConnectionStatus('Connected');
//             };

//     eventSource.onmessage = (event) => {
//         try {
//           console.log('Received SSE data:', event.data);
//           const newData = JSON.parse(event.data);
//           setData(newData);
//         } catch (error) {
//           console.error('Error processing SSE data:', error);
//           setError('Error processing data');
//         }
//       };

//       eventSource.onerror = (error) => {
//         console.error('EventSource failed:', error);
//         setError('Connection failed');
//         setConnectionStatus('Error');
//         eventSource.close();
//         // 연결 재시도
//         setTimeout(connectSSE, 5000);
//       };
//     };

//     connectSSE();

//     return () => {
//         if (eventSource) {
//             console.log("Closing SSE connection");
//             eventSource.close();
//           }
//     };
// }, []);

// if (error) {
//     return <div>Error: {error}</div>;
// }

// if (!data) {
//     return <div>Loading...</div>;
// }

// return (
//     <div>
//         <h1>DLL Callback Data</h1>
//         <pre>{JSON.stringify(data, null, 2)}</pre>
//     </div>
// );
// }
