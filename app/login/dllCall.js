'use client'

//일단 됨.

import { useEffect, useState } from 'react';
import { useGlobalState } from '../../lib/GlobalState';

export default function DllCall() {
    const [data, setData] = useState(null);
  const [error, setError] = useState(null);
  const { state } = useGlobalState();

  useEffect(() => {
    if (state.data) {
      setData(state.data);
    }
  }, [state]);

  if (error) {
    return <div>dllCalljs Error: {error.message}</div>;
  }

  if (!data) {
    return <div>Loading...</div>;
  }

  return (
    <div>
      <h1>DLL Callback Data</h1>
      <pre>{JSON.stringify(data, null, 2)}</pre>
    </div>
  );
}
    
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
//     const eventSource = new EventSource('http://localhost:3000/api/sse');
//     console.log("Connecting to SSE...");

//     eventSource.onopen = function() {
//         console.log("SSE connection opened");
//     };

//     eventSource.onmessage = function(event) {
//         console.log('Received SSE data:', event.data);
//         setData(JSON.parse(event.data));
//     };

//     eventSource.onerror = function(event) {
//         console.error('SSE error:', event);
//         setError('Error connecting to SSE');
//         eventSource.close();
//     };

//     return () => {
//         eventSource.close();
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
