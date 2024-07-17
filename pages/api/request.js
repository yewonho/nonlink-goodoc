import { SendDllMethod } from '../../lib/bridgeHandler';


export async function processData(data) {
    const memberData = data;
  
    switch (memberData.eventId) {
      case cancelChartReceipt: // 접수취소
        members = [...members, memberData];
        console.log("케이스 0", memberData)
        await sendResponseToDll(102, memberData);
        break;

      case changeRoom: // 진료실 변경
        members = [...members, memberData];
        await sendResponseToDll(106, memberData);
        break;

      case changeStatus: // 상태 변경
        members = members.filter(member => member.cellphone !== memberData.cellphone);
        await sendResponseToDll(108, memberData);
        break;

      case cancelMessages: //취소 사유 리스트
        members = members.map(member => 
          member.cellphone === memberData.cellphone ? { ...member, ...memberData } : member
        );
        await sendResponseToDll(302, memberData);
        break;

      case 320: // ???
        members = members.map(member => 
            member.cellphone === memberData.cellphone ? { ...member, ...memberData } : member
        );
        await sendResponseToDll(320, memberData);
        break;

      case findNonLinkReceipts: // 전체 환자 리스트 호출
        members = members.map(member => 
            member.cellphone === memberData.cellphone ? { ...member, ...memberData } : member
        );
        await sendResponseToDll(400, memberData);
        break;

      case findNonLinkReceipt: // 진료실 정보 호출
        members = members.map(member => 
            member.cellphone === memberData.cellphone ? { ...member, ...memberData } : member
        );
        await sendResponseToDll(402, memberData);
        break;

      case findNonLinkReceipt: // 단일 환자 리스트 호출
        members = members.map(member => 
            member.cellphone === memberData.cellphone ? { ...member, ...memberData } : member
        );
        await sendResponseToDll(406, memberData);
        break;

      case getResidentRegistrationNumberfromPatient: // 환자정보 호출
        members = members.map(member => 
            member.cellphone === memberData.cellphone ? { ...member, ...memberData } : member
        );
        await sendResponseToDll(410, memberData);
        break;     

      default:
        console.log(`Unhandled eventId: ${memberData.eventId}`);
        break;
    }
    }


// DLL에 응답하는 함수
async function sendRequestToDll(requestId, memberData) {
    console.log(`Responding to DLL with eventId: ${requestId}`);
    console.log('Member data:', memberData);
  
    const methodName = 'EdgeGdlSendRequest'; // EdgeGdlSendRequest / EdgeGdlSendResponse
  
    let requestdata = {};

  if(requestId === 102 ){
    const chartReceptnResultId1 = uuidv4();
    requestdata = {
      eventId : 102,
        jobId :"AD929DSI091",
        hospitalNo :"10000002",
        patntChartId:"1234",
        message:"환자 요청",
        chartReceptnResultId1:"201905010007",
        chartReceptnResultId2:"",
        chartReceptnResultId3:"",
        chartReceptnResultId4:"",
        chartReceptnResultId5:"",
        chartReceptnResultId6:"",
        deptCode:"80",
        deptNm:"한방내과",
        doctrCode:"7",
        doctrNm:"칠번의",
        roomCode:"104",
        roomNm:"일반진료 01",
        receptStatusChangeDttm: "2019-06-04T02:59:09.151Z"
    }
      
   } else if (responseId === 106) {
      const chartReceptnResultId1 = uuidv4(); // 임의로 생성한 값
      requestdata = {
        eventId:106,
        jobId:"123414106",
        hospitalNo: "12345678",
        receptionUpdateDto: 
        {
        chartReceptnResultId1: "1",
        chartReceptnResultId2: "",
        chartReceptnResultId3: "",
        chartReceptnResultId4: "",
        chartReceptnResultId5: "",
        chartReceptnResultId6: "",
        deptCode: "200",
        deptNm: "예방접종",
        doctrCode: "13579",
        doctrNm: "나의사",
        roomCode: "100",
        roomNm: "토마토방",
        patntChartId: "1",
        status: "C04"
        },
        roomChangeDttm: "2019-05-09T11:15:41.944Z"
      };

    } else if (responseId === 108) {
      const chartReceptnResultId1 = uuidv4(); // 임의로 생성한 값
      requestdata = {
        eventId:108,
        jobId:"1231245423",
        hospitalNo: "12345678",
        receptionUpdateDto: {
        chartReceptnResultId1: "1",
        chartReceptnResultId2: "",
        chartReceptnResultId3: "",
        chartReceptnResultId4: "",
        chartReceptnResultId5: "",
        chartReceptnResultId6: "",
        deptCode: 200,
        deptNm: "예방접종",
        doctrCode: 13579,
        doctrNm: "부고장",
        memo: "string",
        patntChartId: "string",
        roomCode: 100,
        roomNm: "토마토방",
        status: "F05"
        },
        newChartReceptnResultId1:"",
        newChartReceptnResultId2:"",
        newChartReceptnResultId3:"",
        newChartReceptnResultId4:"",
        newChartReceptnResultId5:"",
        newChartReceptnResultId6:"",
        receptStatusChangeDttm: "2019-05-14T07:39:56.539Z"
      };

    } else if (responseId === 302) {
      const chartReceptnResultId1 = uuidv4(); // 임의로 생성한 값
      requestdata = {
        eventId:302,
        jobId:"58806775366641EB8D70F5669838A579",
        hospitalNo:"16161616"
      };

    } else if (responseId === 320) {
        const chartReceptnResultId1 = uuidv4(); // 임의로 생성한 값
        requestdata = {
          eventId: 320,
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

    } else if (responseId === 400) {
        const chartReceptnResultId1 = uuidv4(); // 임의로 생성한 값
        requestdata = {
            eventId:400,
            jobId:"31FBBE258AFB4A0FAD4D5175B7FB906F",
            hospitalNo:"16161616",
            startDttm:"2024-06-11T15:00:00.000Z",
            endDttm:"2024-06-12T14:59:59.999Z",
            changeDttm:"",
            receptnResveType:null,
            take:50,
            skip:0
        };

    } else if (responseId === 402) {
        const chartReceptnResultId1 = uuidv4(); // 임의로 생성한 값
        requestdata = {
            eventId:402,
            hospitalNo:"16161616",
            jobId:"0DF06139D09C4DF38DA7B68300F5281D"
        };

    } else if (responseId === 406) {
        const chartReceptnResultId1 = uuidv4(); // 임의로 생성한 값
        requestdata = {
          eventId: 406,
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

    } else if (responseId === 410) {
        const chartReceptnResultId1 = uuidv4(); // 임의로 생성한 값
        requestdata = {
          eventId: 410,
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