export default function swDev() {
  let swUrl = `${process.env.PUBLIC_URL}/sw.js`;
  navigator.serviceWorker
    .register(swUrl)
    .then((response) => {
      console.warn("Service Worker registered with response:", response);
    })
    .catch((error) => {
      console.error("Service Worker registration failed:", error);
    });
}
