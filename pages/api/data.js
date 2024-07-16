import { updateMembers } from './queue';

export default function handler(req, res) {
  const currentMembers = updateMembers();
 // console.log("데이터 js currentMembers", currentMembers);
 // console.log("데이터 js currentMembers type", typeof currentMembers);
 // console.log("데이터 js currentMembers length", Array.isArray(currentMembers) ? currentMembers.length : "not an array");
  
  if (Array.isArray(currentMembers) && currentMembers.length > 0) {
   // console.log("데이터 js 이프", currentMembers);
    res.status(200).json({ members: currentMembers });
  } else {
    res.status(204).end(); // 204 상태 코드를 설정하고 본문을 포함하지 않음
  }
}
