'use client'

import { useState } from 'react';

const DllCaller = () => {
  const [result, setResult] = useState(null);
  const [error, setError] = useState(null);

  const callDll = async () => {
    console.log('일단 들어오긴 했음')
    try {
      console.log('트라이 들어옴')
      const response = await fetch('/api/post/bridgeInit', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ param: 'login' }), // 필요한 매개변수를 JSON으로 전달
      });

      if (!response.ok) {
        console.log('텍스트찍음')
        const errorText = await response.text();
        throw new Error(`Server error: ${response.status} ${response.statusText} - ${errorText}`);
      }

      const data = await response.json();
      setResult(data);
    } catch (err) {
      setError(err.message);
      console.log('에러확인')
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