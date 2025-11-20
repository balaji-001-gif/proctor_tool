function startProctor(opts){
  if(!opts || !opts.session) return;
  const session = opts.session;

  async function capture(){
    const stream = await navigator.mediaDevices.getUserMedia({video:true});
    const video = document.createElement("video");
    video.srcObject = stream;
    await video.play();
    const canvas = document.createElement("canvas");
    canvas.width=640;canvas.height=480;
    canvas.getContext("2d").drawImage(video,0,0);
    const base64 = canvas.toDataURL('image/png').split(',')[1];
    await fetch('/api/method/proctor_tool.api.upload_evidence',{
      method:"POST",
      headers:{"Content-Type":"application/x-www-form-urlencoded"},
      body:new URLSearchParams({session:session, filename:'snap.png', content:base64})
    });
  }
  setInterval(capture,60000);
}
