'use client'

import { useState } from 'react';

const DllCaller = () => {
  const [result, setResult] = useState(null);
  const [error, setError] = useState(null);

  const callDll = async () => {
    try {
      const response = await fetch('/api/post/bridgeInit', {
        method: 'POST',
        // headers: {
        //   'Content-Type': 'application/json',
        // },
        body: JSON.stringify({ param: 'login' }), // 필요한 매개변수를 JSON으로 전달
      });

      if (!response.ok) {
        const errorText = await response.text();
        throw new Error(`Server error: ${response.status} ${response.statusText} - ${errorText}`);
      }

      const data = await response.json();
      setResult(data);
    } catch (err) {
      setError(err.message);
      console.error('Error:', err);
    }
  };

  return (
    <div>
      <button onClick={callDll}>Call DLL Method</button>
      {result && <div>Result: {JSON.stringify(result)}</div>}
      {error && <div>Error: {error}</div>}
    </div>
  );
};

export default DllCaller;