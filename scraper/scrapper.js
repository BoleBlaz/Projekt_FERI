const axios = require('axios');
const cheerio = require('cheerio');
const db = require('mysql2-promise')();
const proj4 = require('proj4');
const puppeteer = require('puppeteer');
const { Cluster } = require('puppeteer-cluster');
const cron = require('node-cron');


db.configure({
  host: '212.44.101.98',
  user: 'beofle38_efi',
  password: 'SamoDaDela',
  database: 'beofle38_feri_projekt',
  port: 3306
});

process.setMaxListeners(200);
async function scrape(url) {
  let browser;

  try {
    //const projection = '+proj=tmerc +lat_0=0 +lon_0=15 +k=0.9999 +x_0=500000 +y_0=-5000000 +ellps=bessel +towgs84=577.326,90.129,463.919,5.137,1.474,5.297,2.4232 +units=m +no_defs';
    await db.execute('SELECT 1');
    console.log('Database connection successful!');

    await db.query('TRUNCATE TABLE scrapedData');
    console.log('Deleted all data from the table!');

    const response = await axios.get(url);
    const $ = cheerio.load(response.data);

    const tableRows = $('#content table tbody tr');
    const rowCount = tableRows.length;


    console.log('Number of rows:', rowCount);

    const rowsData = [];
    let previousLink = null;
    const finalURLPromises = tableRows.map(async (index, row) => {
      const columns = $(row).find('td');
      const roadContent = $(columns[0]).text().trim();
      const locationContent = $(columns[1]).text().trim();
      const directionContent = $(columns[2]).text().trim();
      const numVehiclesContent = $(columns[3]).text().trim();
      const speedContent = $(columns[4]).text().trim();
      const spaceContent = $(columns[5]).text().trim();
      const filledContent = $(columns[6]).text().trim();
      const timeContent = $(columns[7]).text().trim();
      const conditionContent = $(columns[8]).text().trim();
      let link = $(row).find('td > a').attr('href');
      if (link == null || link == "") {
        link = previousLink;
    } else {
        previousLink = link;
    }
      console.log(link);


      //  const getLink = $(columns[1]).find('a');
      // const link = $(getLink).attr('href');
      //console.log(link);

      //const initialLink = 'http://www.geopedia.si/#T1239_L5609_F1034321';



      //const url = 'http://www.geopedia.si/#T1239_F5609:1100111_x467134_y102724_s17_b4';
      /*let getX = url.indexOf('x');
      let getY = url.indexOf('y');
      let getS = url.indexOf('_s');
      let x = url.substring(getX + 1, getY - 1);
      let y = url.substring(getY + 1, getS - 1);
      console.log(x);
      console.log(y);*/

      const rowData = [
        roadContent,
        locationContent,
        directionContent,
        numVehiclesContent,
        speedContent,
        spaceContent,
        filledContent,
        timeContent,
        conditionContent,
        link
      ];

      rowsData.push(rowData);
    }).get();


    const chunkSize = 1549;
    const chunks = [];
    for (let i = 0; i < rowsData.length; i += chunkSize) {
      const chunk = rowsData.slice(i, i + chunkSize);
      chunks.push(chunk);
    }



  for (const chunk of chunks) {
    try {
      const placeholders = chunk.map(() => '(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)').join(', ');
      const values = chunk.flatMap(rowData => rowData);
      const query = `INSERT INTO scrapedData (road, location, direction, numVehicles, speed, space, filled, time, conditions, link) VALUES ${placeholders}`;
      await db.query(query, values);
      console.log(`Inserted ${chunk.length} rows into the database!`);
    } catch (error) {
      console.error('Error inserting rows:', error);
    }
  }

} catch (error) {
  console.error('Failed to connect to the database:', error);
} finally {
  if (browser) {
    await browser.close();
  }
}
}
cron.schedule('0 * * * *', () => {
  var time = Date();
  console.log({time});
  scrape('http://portal.drsc.si/traffic/loclist_si.htm');
});


scrape('http://portal.drsc.si/traffic/loclist_si.htm');

