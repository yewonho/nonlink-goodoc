import edge from 'edge-js';
import path from 'path';

class SimpleQueue {
  constructor() {
    this.queue = [];
  }

  push(item) {
    console.log("푸시 큐")
    this.queue.push(item);
  }

  shift() {
    console.log("시프트 큐")
    return this.queue.shift();
  }

  get length() {
    return this.queue.length;
  }
}

const dataQueue = new SimpleQueue();
let members = [];

// 큐에 데이터를 추가하는 함수
export function addToQueue(data) {
    console.log("에드투큐", data)
  dataQueue.push(data);
}

// 큐에서 데이터를 꺼내고 멤버 목록을 업데이트하는 함수
export function updateMembers() {
    console.log("업데이트 멤버 큐")
    if (dataQueue.length > 0) {
        console.log("업데이트 멤버 큐 이프")
      const newData = dataQueue.shift();
      const { pjson } = newData;
      try {
        const memberData = JSON.parse(pjson);
        members = [...members, memberData]; // 기존 데이터에 새 데이터를 추가
      } catch (error) {
        console.error('Failed to parse JSON:', error);
      }
    }
    return Array.isArray(members) ? members : []; // 배열이 아닌 경우 빈 배열 반환
  }

// 이 API는 DLL이 호출하여 데이터를 큐에 추가
export default function handler(req, res) {
    console.log("dll데이터 추가 큐",req.body)
  if (req.method === 'POST') {
    const { pjson, nlen } = req.body;
    addToQueue({ pjson, nlen });
    res.status(200).json({ message: 'Data received' });
  } else {
    res.status(405).json({ message: 'Method not allowed' });
  }
}
