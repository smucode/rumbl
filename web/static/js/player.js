let Player = {
  player: null,
  init(domId, playerId, onReady) {
    console.log('init',domId, playerId)
    window.onYouTubeIframeAPIReady = () => {
      this.onIframeReady(domId, playerId, onReady)
    }
    let scr = document.createElement("script")
    scr.src = "//youtube.com/iframe_api"
    document.head.appendChild(scr)
  },
  onIframeReady(domId, playerId, onReady) {
    console.log('onIframeReady',domId, playerId)
    this.player = new YT.Player(domId, {
      height: "360",
      width: "420",
      videoId: playerId,
      events: {
        onReady: (event => onReady(event)),
        onStateChange: (event => this.onPlayerStateChange(event))
      }
    })
  },
  onPlayerStateChange(event) {
    console.log('onPlayerStateChange')
  },
  getCurrentTime() {
    console.log('getCurrentTime')
    return Math.floor(this.player.getCurrentTime() * 1000)
  },
  seekTo(millSek) {
    console.log('seekTo')
    return this.player.seekTo(millSek / 1000)
  }
}

export default Player
