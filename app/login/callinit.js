'use client'

//일단 됨.

import { useEffect, useState } from 'react';

export default function Callinit() {
    const [data, setData] = useState(null);
    const [error, setError] = useState(null);



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