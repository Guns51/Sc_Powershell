const mineflayer = require('mineflayer');
const { Entity } = require('prismarine-viewer/viewer');

const bot = mineflayer.createBot({
    host: 'mc.minebox.fr',
    //port: 25565,
    username: 'gunsalexandre@gmail.com',
    version: 1.13,
    auth: 'microsoft',
});

bot.on("resourcePack",function acceptpack(url,hash){
    console.log(url)
    console.log(hash)
    bot.acceptResourcePack()
  })
  bot.on("chat", function(username,message){
      if (username === bot.username) return
      console.log(message)
  })
  
  const mineflayerViewer = require('prismarine-viewer').mineflayer
    bot.once('spawn', async () => {
      mineflayerViewer(bot, { port: 3007, firstPerson: true })
  })
  
const north = 2*(Math.PI)    //  2π
const west = Math.PI / 2     //  π/2
const south = Math.PI        //  π
const east = 3*(Math.PI / 2) //  3π/2    
const south_east = 5*(Math.PI / 4)
const south_west = 3*(Math.PI / 4)
const north_east = 7*(Math.PI / 4)
const north_west = Math.PI / 4

// Attendez que le bot soit prêt
bot.once('spawn', async () => {
    antiAFK()
    while(1)
    {
        var mobn = bot.nearestEntity(entity => entity.type === "mob")
        if (mobn)
        {      
            bot.attack(mobn)
            console.log("coucouc", mobn)
        }
        //if (bot.inventory.slots.filter(slot => slot).length === 36) {console.log("INVENTORY FULL !!!!!!!")}
    await new Promise(resolve => setTimeout(resolve, 750));
    }
    
  });

async function antiAFK(){
    var i = 0
    await new Promise(resolve => setTimeout(resolve, 2000));
    while(1)
    {

        await bot.look(south,0)
        bot.setControlState("back",true)
        await new Promise(resolve => setTimeout(resolve, 500));
        bot.setControlState("back",false)
        bot.setControlState("forward",true)
        await bot.look(south,0)
        await new Promise(resolve => setTimeout(resolve, 700));
        bot.setControlState("forward",false)

        await new Promise(resolve => setTimeout(resolve, 10000));
    }
}