'use client'

//일단 됨.

import { useEffect, useState } from 'react';

export default function Home() {
    const [data, setData] = useState(null);
    const [error, setError] = useState(null);

    useEffect(() => {
        async function fetchData() {
            try {
               console.log('트라이 시작');
                const response = await fetch('../api/post/bridgeInit', {
                    method: 'POST',
                    headers: {
                      'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                      methodName: 'EdgeGdlInit', // 호출할 메서드 이름 EdgeGdlLogin , EdgeGdlInit, EdgeGdlDeInit, EdgeGdlSendRequest
                      payload: {
                         data: {
                        //   cellphone : parseInt(cellphone, 10),
                        //   regNum:parseInt(regNum, 10),
                        //   eventId:parseInt(eventId, 10),
                        //   jobId:String(jobId)},
                        //  length: parseInt(length, 10)



                        // 로그인용
                        // hospitalCode: 20000351,
                        // userId: 'e20000351',
                        // password: 'goodoc123!'



                        //init용
                                  chartCode: 3350,
                                  hospitalCode: '20000351',
                                  initType: 0
                      }
                    }})
                   
                });

                if (!response.ok) {
                  console.log('리스펀스 에러'+response.ok);
                  throw new Error('Network response was not ok');
                }

                const result = await response.json();
                setData(result);
            } catch (error) {
                setError(error.message);
            }
        }

        fetchData();
    }, []);

    if (error) {
      return <div>Error: {error.message}</div>;
    }
  
    if (!data) {
      return <div>Loading...</div>;
    }
  
    return (
      <div>
        <h1>DLL Method Result</h1>
        <pre>{JSON.stringify(data, null, 2)}</pre>
      </div>
    );
  }



// dll 로드 정상적으로 되는거. 
// const callDllMethod = async () => {
//     try {
//       const res = await fetch('../api/post/bridgeInit', {
//         method: 'POST',
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: JSON.stringify({
//           chartCode: 3350,
//           hospitalCode: '20000351',
//           initType: 0
//         }),
//       });

//       const data = await res.json();
//       if (res.ok) {
//         console.log(data.result)
//         setData(data.result);
//       } else {
//         console.log(data.result)
//         setError(data.error);
//       }
//     } catch (err) {
//       setError('Failed to call API');
//     }
//   };

//   return (
//     <div>
//       <h1>DLL Method Caller</h1>
//       <button onClick={callDllMethod}>Call DLL Method</button>
//       {data && <pre>{JSON.stringify(data, null, 2)}</pre>}
//       {error && <pre style={{ color: 'red' }}>{error}</pre>}
//     </div>
//   );

//}