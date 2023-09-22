//178.33.40.222:25600

const mineflayer = require('mineflayer')
const bot = mineflayer.createBot({
  host: 'erisium.com', // optionel
  //port: 25600, // optionel
  username: 'gunsalexandre@gmail.com', // l'email et le mot de passe sont requis seulement pour les serveurs
  //password: '12345678', // online-mode=true
  version: false, // faux, corresponds pour la detection automatique(par défaut), met "1.8.8" par exemple si tu a besoin d'une version specifique
  auth: 'microsoft', // optionel; par defaut utilise mojang, si vous utilisez un compte microsoft, preciser 'microsoft'
})

bot.on("login",async function loginmessage(){
    await new Promise(resolve => setTimeout(resolve, 5000))
    bot.chat("salut")
    return
})

bot.on("chat", function(username,message){
    if (username === bot.username) return
    console.log(message)
})

const mineflayerViewer = require('prismarine-viewer').mineflayer
bot.once('spawn', () => {
 mineflayerViewer(bot, { port: 3007, firstPerson: true })
})

// erreur de code, ou raison de kick:
bot.on('kicked', (reason, loggedIn) => console.log(reason, loggedIn))
bot.on('error', err => console.log(err))

