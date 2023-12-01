const mineflayer = require('mineflayer');
const { Vec3 } = require('vec3');

const bot = mineflayer.createBot({
  host: 'ipServeur',
  //port: 25565,
  username: 'email',
  version: 1.18,
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
  


function blockToHarvest () {
return bot.findBlock({
    point: bot.entity.position,
    maxDistance: 3,
    matching: (block) => {
    return block && block.type === bot.registry.blocksByName.melon.id && block.metadata === 0
    }
})
}


async function forwardEnterLine (beginORend) {
  
  var finalDistance = (bot.entity.position[letterChangeHorizontal].valueOf());
  //bot.setControlState('forward',true);
  console.log("look...");
  await bot.look((bot.entity.yaw.valueOf() + beginORend),0 );
  bot.setControlState('forward',true);
  while(1)
  {
      var distance =  Math.abs(bot.entity.position[letterChangeHorizontal].valueOf() - (finalDistance)); // il faut valeur actuelle - valeur depart
      console.log("distance : ", distance);
      if(distance+0.5 >= spaceEnterLine)
      {
        bot.setControlState('forward',false);
        console.log("look...");
        await bot.look((bot.entity.yaw.valueOf() + beginORend),0 );
        await pauseBeginLine();
        break;
      }
      await new Promise(resolve => setTimeout(resolve, 100));
  }
  
}



async function pauseBeginLine() // 2 premier block
{
  console.log("reaching 2 block...")
  bot.setControlState('forward',true);
  bot.setControlState('sprint',true);
  var positioDebutNouvelleLigne = bot.entity.position[letterChangeVertical].valueOf()
  while( (Math.abs(positioDebutNouvelleLigne - bot.entity.position[letterChangeVertical].valueOf())) < 2 )
  {
    const toHarvest = blockToHarvest()
    if (toHarvest) {
      console.log("casse")
      await bot.dig(toHarvest,"ignore","raycast")
    }
    await new Promise(resolve => setTimeout(resolve, 100));
  }
}


async function returnToStart(beginORend)
{
  console.log("returnToStart...");
  const valueLetterHorizontal = Math.abs(vecBeginLastLine[letterChangeHorizontal]);
  if( Math.abs((bot.entity.position[letterChangeHorizontal] - valueLetterHorizontal)) < 2)
  {
    console.log(bot.entity.position[letterChangeHorizontal] - valueLetterHorizontal)
    console.log("look...");
    await bot.look((bot.entity.yaw.valueOf() + beginORend),0 );
    var finalDistance = (bot.entity.position[letterChangeHorizontal].valueOf());
    bot.setControlState('forward',true);
    bot.setControlState('sprint',true);
    console.log("distanceTotalHorizontal", distanceTotalHorizontal)
    while(1)
    {
        var distance =  Math.abs(bot.entity.position[letterChangeHorizontal].valueOf() - finalDistance); // il faut valeur actuelle - valeur depart
        console.log("distance : ", distance);
        if((distance+ 1.25) >= distanceTotalHorizontal)// +2 pour lecart des blocks
        {
          bot.setControlState('forward',false);
          bot.setControlState('sprint',false);
          console.log("look...");
          await bot.look((bot.entity.yaw.valueOf() + beginORend),0 );
          await pauseBeginLine();
          break;
        }
        await new Promise(resolve => setTimeout(resolve, 100));
    }
    return true;
  }
}

async function inventory()
{
  if(bot.inventory.slots.filter(slot => slot).length == 36)
  {

  }
}

  
async function loop () {

try {
    while (1) {
    const toHarvest = blockToHarvest()
    var positionBot = bot.entity.position
    //si le block est melon
    if (toHarvest) {
        console.log("detect melon")
        await bot.dig(toHarvest,"ignore","raycast")
        //bot.look(0,0)
    }
    //si le bot a atteint le bout de la ligne
    else if (~~positionBot[letterChangeVertical] == valueVerticalChangeEnd)
    {
        console.log("fin");
        bot.setControlState("forward",false);
        bot.setControlState('sprint',false);
        await new Promise(resolve => setTimeout(resolve, 500));
        if(await returnToStart(east))
        {
          break;
        }
        await forwardEnterLine(west);
        bot.setControlState("forward",true)
        bot.setControlState("sprint",true)
        console.log("avance");
        break;
    }
    else if (~~positionBot[letterChangeVertical] == valueVerticalChangeBengin)
    {
        console.log("debut")
        bot.setControlState("forward",false)
        bot.setControlState('sprint',false)
        await new Promise(resolve => setTimeout(resolve, 500));
        if(await returnToStart(west))
        {
          break;
        }
        await forwardEnterLine(east);
        bot.setControlState("forward",true)
        bot.setControlState("sprint",true)
        console.log("avance");
        break
    }
    else {
        console.log("none")
        break
    }
    }
} catch (e) {
    console.log(e)
}

setTimeout(loop, 200)
}

const spaceEnterLine = 5
const components = ['x', 'y', 'z'];

/////////////////////////(--- VERTICAL ---)//////////////////////////////////////////
const vecBeginFistLine = new Vec3 (-6430, 52, -116806);     // A MODIF //###########################################
const vecEndtFistLine = new Vec3 (-6369, 52, -116806);      // A MODIF //###########################################

for (const component of components) {
  if (vecBeginFistLine[component] === vecEndtFistLine[component]) {
  } else {
    var letterChangeVertical = component
  }
}
//valeur de la composante changeante
var valueVerticalChangeBengin = ~~(vecBeginFistLine[letterChangeVertical])
var valueVerticalChangeEnd = ~~(vecEndtFistLine[letterChangeVertical])
/////////////////////////////////////////////////////////////////////////////////////

/////////////////////////(--- HORIZONTAL ---)////////////////////////////////////////

const vecBeginLastLine = new Vec3 (-6430, 52, -116827);    // A MODIF //###########################################
const vecEndLastLine = new Vec3 (-6369, 52, -116827);      // A MODIF //###########################################

for (const component of components) {
    if (vecBeginFistLine[component] === vecBeginLastLine[component]) {
    } else {
      var letterChangeHorizontal = component
    }
}

/////////////////////////////////////////////////////////////////////////////////////

const distanceTotalHorizontal = Math.abs(vecBeginFistLine[letterChangeHorizontal] - vecBeginLastLine[letterChangeHorizontal])

// Savoir 


const north = 2*(Math.PI)    //  2π
const west = Math.PI / 2     //  π/2
const south = Math.PI        //  π
const east = 3*(Math.PI / 2) //  3π/2    



bot.once("spawn",async () => {
  await bot.look(east,0)
  bot.setControlState("forward",true);
  bot.setControlState("sprint",true);
  await pauseBeginLine();
  loop();
})







