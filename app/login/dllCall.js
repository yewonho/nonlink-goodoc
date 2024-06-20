'use client'

//일단 됨.

import { useEffect, useState } from 'react';

export default function DllCall() {
    const [data, setData] = useState(null);
    const [error, setError] = useState(null);

    console.log("dllCall 실행");
    useEffect(() => {
      async function fetchData() {
        console.log("Fetching data...");
        try {
            const response = await fetch('/api/post/dllCallback', {
              method: 'POST', // POST 요청으로 변경
              headers: {
                  'Content-Type': 'application/json'
              },
              body: JSON.stringify({
                  pjson : {
                    cellphone : 0,
                    regNum : "",
                    eventId :0,
                    jobId : ""
                   }
              })
          });
          console.log("Fetch response received",response );


            if (!response.ok) {
                throw new Error('Network response was not ok', "Network response was not ok:", response.status, response.statusText);
            }

            const result = await response.json();
            console.log("리스펀스 데이터" +  JSON.stringify(result, null, 2))
            setData(result);
        } catch (error) {
          console.log("Error in fetchData:", error);  
          setError(error);
        }
    }

    fetchData();
}, []);

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
