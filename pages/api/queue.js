import edge from 'edge-js';
//import { v4 as uuidv4 } from 'uuid';
import { SendDllMethod } from '../../lib/bridgeHandler';

class SimpleQueue {
  constructor() {
    this.queue = [];
  }

  push(item) {
    this.queue.push(item);
  }

  shift() {
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
  dataQueue.push(data);
}

// ID에 따른 데이터 처리 함수
export async function processData(data) {
  const memberData = data;

  switch (memberData.eventId) {
    case 0:
      // 데이터 누적 및 응답
      members = [...members, memberData];
      console.log("케이스 0", memberData)
      await sendResponseToDll(1, memberData);
      break;
    case 100:
      // 데이터 누적 및 응답
      members = [...members, memberData];
      await sendResponseToDll(101, memberData);
      break;
    case 102:
      // 데이터 제외 및 응답
      members = members.filter(member => member.cellphone !== memberData.cellphone);
      await sendResponseToDll(103, memberData);
      break;
    case 108:
      // 데이터 수정 및 응답
      members = members.map(member => 
        member.cellphone === memberData.cellphone ? { ...member, ...memberData } : member
      );
      await sendResponseToDll(109, memberData);
      break;
    default:
      console.log(`Unhandled eventId: ${memberData.eventId}`);
      break;
  }
}

// DLL에 응답하는 함수
async function sendResponseToDll(responseId, memberData) {
  console.log(`Responding to DLL with eventId: ${responseId}`);
  console.log('Member data:', memberData);

  const methodName = 'EdgeGdlSendResponse'; // EdgeGdlSendRequest / EdgeGdlSendResponse

  let requestdata = {};
if(responseId === 1 ){
  requestdata = {
    eventId: 1,
    jobId: memberData.jobId,
    code : 200,
    message:"",
    result: {
        hospitalNo: 20000351,
        patntList : []
    }
  }
    
 } else if (responseId === 101) {
    const chartReceptnResultId1 = uuidv4(); // 임의로 생성한 값
    requestdata = {
      eventId: 101,
      jobId: memberData.jobId,
      code: 200,
      message: "",
      result: {
        hospitalNo: memberData.hospitalNo,
        patntChartId: memberData.patntChartId,
        regNum: memberData.regNum,
        chartReceptnResultId1,
        chartReceptnResultId2: "",
        chartReceptnResultId3: "",
        chartReceptnResultId4: "",
        chartReceptnResultId5: "",
        chartReceptnResultId6: "",
        roomCode: memberData.roomCode,
        roomNm: memberData.roomNm,
        deptCode: memberData.deptCode,
        deptNm: memberData.deptNm,
        doctrCode: memberData.doctrCode,
        doctrNm: memberData.doctrNm,
        gdid: "",
        ePrescriptionHospital: 0
      }
    };
  } else {
    requestdata = {
      eventId: responseId,
      jobId: memberData.jobId,
      code: 200,
      message: ""
    };
  }

  try {
    const result = await SendDllMethod(requestdata , methodName);
    console.log("Response sent to DLL, result:", result);
  } catch (error) {
    console.error("Error sending response to DLL:", error);
  }
}

// 큐에서 데이터를 꺼내고 멤버 목록을 업데이트하는 함수
export function updateMembers() {
  if (dataQueue.length > 0) {
    const newData = dataQueue.shift();
    processData(newData);
  }
  return Array.isArray(members) ? members : []; // 배열이 아닌 경우 빈 배열 반환
}

// 이 API는 DLL이 호출하여 데이터를 큐에 추가
export default function handler(req, res) {
  if (req.method === 'POST') {
    const { pjson, nlen } = req.body;
    const memberData = JSON.parse(pjson);
    addToQueue(memberData);
    res.status(200).json({ message: 'Data received' });
  } else {
    res.status(405).json({ message: 'Method not allowed' });
  }
}
