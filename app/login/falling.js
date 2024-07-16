'use client'

// pages/index.js
import { useEffect, useState } from 'react';

export default function Home() {
  const [members, setMembers] = useState([]);

  useEffect(() => {
    const fetchData = async () => {
      const response = await fetch('/api/data');
      if (response.status === 200) {
        const result = await response.json();
        console.log("Fetched members:", result.members);
        setMembers(result.members);
      } else if (response.status === 204) {
        setMembers([]); // 데이터가 없을 때 빈 배열로 설정
      }
    };

    fetchData(); // 컴포넌트가 마운트될 때 한 번 실행

    const intervalId = setInterval(fetchData, 1000); // 5초마다 데이터 폴링

    return () => clearInterval(intervalId); // 컴포넌트가 언마운트될 때 인터벌 클리어
  }, []);

  return (
    <div>
      <h1>Member List</h1>
      {members.length > 0 ? (
        <table>
          <thead>
            <tr>
              <th>Cellphone</th>
              <th>RegNum</th>
              <th>EventId</th>
              <th>JobId</th>
            </tr>
          </thead>
          <tbody>
            {members.map((member, index) => (
              <tr key={index}>
                <td>{member.cellphone}</td>
                <td>{member.regNum}</td>
                <td>{member.eventId}</td>
                <td>{member.jobId}</td>
              </tr>
            ))}
          </tbody>
        </table>
      ) : (
        <p>No data available</p>
      )}
    </div>
  );
}
