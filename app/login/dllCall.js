'use client'

//일단 됨.

import { useEffect, useState } from 'react';

export default function Home() {
    const [data, setData] = useState(null);
    const [error, setError] = useState(null);

//     useEffect(() => {
//         async function fetchData() {
//             try {
//                 const response = await fetch('../api/post/bridgeInit', {
//                     method: 'GET',
                   
//                 });

//                 if (!response.ok) {
//                     throw new Error('Network response was not ok');
//                 }

//                 const result = await response.json();
//                 setData(result);
//             } catch (error) {
//                 setError(error.message);
//             }
//         }

//         fetchData();
//     }, []);

//     if (error) {
//         return <div>Error: {error}</div>;
//     }

//     if (!data) {
//         return <div>Loading...</div>;
//     }

//     return (
//         <div>
//             <h1>DLL Load Result</h1>
//             <pre>{JSON.stringify(data, null, 2)}</pre>
//         </div>
//     );
// }



const callDllMethod = async () => {
    try {
      const res = await fetch('../api/post/bridgeInit', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          chartCode: 3350,
          hospitalCode: '20000351',
          initType: 0
        }),
      });

      const data = await res.json();
      if (res.ok) {
        console.log(data.result)
        setData(data.result);
      } else {
        console.log(data.result)
        setError(data.error);
      }
    } catch (err) {
      setError('Failed to call API');
    }
  };

  return (
    <div>
      <h1>DLL Method Caller</h1>
      <button onClick={callDllMethod}>Call DLL Method</button>
      {data && <pre>{JSON.stringify(data, null, 2)}</pre>}
      {error && <pre style={{ color: 'red' }}>{error}</pre>}
    </div>
  );

}