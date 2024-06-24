// pages/_app.js
import '../styles/globals.css';
import { GlobalStateProvider } from '../lib/GlobalState'; // 전역 상태 파일 경로에 맞게 조정

function MyApp({ Component, pageProps }) {
  return (
    <GlobalStateProvider>
      <Component {...pageProps} />
    </GlobalStateProvider>
  );
}

export default MyApp;