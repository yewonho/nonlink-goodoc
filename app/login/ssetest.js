// 'use client';

// import { useState, useEffect } from 'react';

// export default function Home() {
//   const [data, setData] = useState(null);

//   useEffect(() => {
//     let eventSource;

//     const connectSSE = () => {
//         console.log("Connecting to SSE...");
//         eventSource = new EventSource('/api/sse');
      
//         eventSource.onopen = () => {
//           console.log("SSE connection opened");
//         };
      
//         eventSource.onmessage = (event) => {
//           try {
//             console.log('Received SSE data:', event.data);
//             const newData = JSON.parse(event.data);
//             setData(newData);
//           } catch (error) {
//             console.error('Error processing SSE data:', error);
//           }
//         };
      
//         eventSource.onerror = (error) => {
//           console.error('EventSource failed:', error);
//           eventSource.close();
//           // 연결 재시도
//           setTimeout(connectSSE, 5000);
//         };
//       };

//     connectSSE();

//     const sendSimulatedData = async () => {
//       const simulatedData = {
//         timestamp: new Date().toISOString(),
//         value: Math.random()
//       };

//       try {
//         console.log("트라이")
//         const response = await fetch('/api/sse', {
//           method: 'POST',
//           headers: {
//             'Content-Type': 'application/json'
//           },
//           body: JSON.stringify(simulatedData)
//         });

//         if (!response.ok) {
//           throw new Error(`HTTP error! status: ${response.status}`);
//         }

//         const responseData = await response.json();
//         console.log('POST response:', responseData);
//       } catch (error) {
//         console.error('Error sending simulated data:', error);
//       }
//     };

//     const intervalId = setInterval(sendSimulatedData, 2000);

//     return () => {
//       if (eventSource) {
//         eventSource.close();
//       }
//       clearInterval(intervalId);
//     };
//   }, []);

//   return (
//     <div>
//       <h1>DLL Data</h1>
//       {data ? (
//         <pre>{JSON.stringify(data, null, 2)}</pre>
//       ) : (
//         <p>Waiting for data...</p>
//       )}
//     </div>
//   );
// }
