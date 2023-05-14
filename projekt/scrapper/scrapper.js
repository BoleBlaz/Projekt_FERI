const puppeteer = require('puppeteer');
var fs = require('fs');
const cron = require('node-cron');
//const { title } = require('process');

async function scrape(url) {
  const browser = await puppeteer.launch({ headless: "new" }); 
  const page = await browser.newPage();
  
  await page.goto(url); 
  
  const [el3] = await page.$x('//*[@id="content"]/table/tbody');
  const txt3 = await el3.getProperty('textContent');
  const titleRoad3 = await txt3.jsonValue();


fs.writeFile('traffic.txt', titleRoad3, function(err){
    if (err) throw err;
    console.log('Saved!');
});
 // console.log({ /*titleRoad,titleRoad2*/titleRoad3 });

  await browser.close(); 
}

cron.schedule('0 * * * *', () => {
    var time = Date();
    console.log({time});
    scrape('http://portal.drsc.si/traffic/loclist_si.htm');
  });
  

scrape('http://portal.drsc.si/traffic/loclist_si.htm');
