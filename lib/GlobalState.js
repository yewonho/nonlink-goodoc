// let clients = [];

// export function addClient(client) {
//   clients.push(client);
//   console.log(`Client added. Total clients: ${clients.length}`);
// }

// export function removeClient(clientId) {
//   clients = clients.filter(c => c.id !== clientId);
//   console.log(`Client removed. Remaining clients: ${clients.length}`);
// }

// export function getClients() {
//   return clients;
// }


let clients = new Map();

export function addClient(client) {
    clients.set(client.id, client);
    console.log(`Client added. Client ID: ${client.id}. Total clients: ${clients.size}`);
  }
  
  export function removeClient(clientId) {
    const removed = clients.delete(clientId);
    console.log(`Client removed. Client ID: ${clientId}. Removed: ${removed}. Total clients: ${clients.size}`);
  }
  
  export function getClients() {
    console.log(`Getting clients. Total clients: ${clients.size}`);
    return Array.from(clients.values());
  }
  
  export function getClientCount() {
    return clients.size;
  }






// import { createContext, useContext, useReducer } from 'react';

// const GlobalStateContext = createContext();
// const GlobalDispatchContext = createContext();

// const initialState = {
//   data: null,
// };

// function globalStateReducer(state, action) {
//   switch (action.type) {
//     case 'SET_DATA':
//       return {
//         ...state,
//         data: action.payload,
//       };
//     default:
//       return state;
//   }
// }

// let globalState = initialState;
// let globalDispatch = () => {};

// export function GlobalStateProvider({ children }) {
//   const [state, dispatch] = useReducer(globalStateReducer, initialState);

//   globalState = state; // 전역 변수에 상태 저장
//   globalDispatch = dispatch; // 전역 변수에 디스패치 저장

//   console.log('GlobalState initialized:', globalState);

//   return (
//     <GlobalStateContext.Provider value={state}>
//       <GlobalDispatchContext.Provider value={dispatch}>
//         {children}
//       </GlobalDispatchContext.Provider>
//     </GlobalStateContext.Provider>
//   );
// }

// export function useGlobalState() {
//   return useContext(GlobalStateContext);
// }

// export function useGlobalDispatch() {
//   return useContext(GlobalDispatchContext);
// }

// // 전역 상태 반환 함수
// export function getGlobalState() {
//  // console.log('getGlobalState called:', globalState);
//   return globalState;
// }

// // 전역 디스패치 액션 함수
// export function globalDispatchAction(action) {
//   console.log("디스패치 액션", action);
//   globalDispatch(action);
// }
