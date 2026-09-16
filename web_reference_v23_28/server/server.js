const http=require('http'),fs=require('fs'),path=require('path'),crypto=require('crypto');
const PORT=Number(process.env.PORT||8787),ROOT=path.join(__dirname,'..','prototype'),DATA=path.join(__dirname,'server_data.json');
const now=()=>Date.now(),id=(p='id')=>p+'_'+crypto.randomBytes(6).toString('hex'),clamp=(v,a,b)=>Math.max(a,Math.min(b,v));
let db={users:{},sessions:{},presence:{},parties:{},invites:{},rewards:{},activities:{}};
try{db={...db,...JSON.parse(fs.readFileSync(DATA,'utf8'))}}catch{}
const save=()=>{try{fs.writeFileSync(DATA,JSON.stringify(db,null,2))}catch{}};
const json=(res,code,obj)=>{res.writeHead(code,{'Content-Type':'application/json','Access-Control-Allow-Origin':'*'});res.end(JSON.stringify(obj))};
const body=req=>new Promise((ok,bad)=>{let s='';req.on('data',d=>{s+=d;if(s.length>1e6)req.destroy()});req.on('end',()=>{try{ok(s?JSON.parse(s):{})}catch(e){bad(e)}})});
const token=req=>(req.headers.authorization||'').replace(/^Bearer\s+/,'');
const user=req=>db.sessions[token(req)]||null;
const partyOf=u=>Object.values(db.parties).find(p=>p.members.includes(u))||null;
const alivePresence=u=>{let p=db.presence[u];return p&&now()-p.updated<12000?p:null};
const sameMapEligible=(party,map,x,y,range=900)=>party.members.filter(u=>{let p=alivePresence(u);if(!p||p.map!==map)return false;if(x==null||y==null)return true;return Math.hypot((p.x||0)-x,(p.y||0)-y)<=range});
const reward=(u,r)=>{(db.rewards[u]??=[]).push(r)};
const safeUser=u=>db.users[u]?{user:u,role:db.users[u].role||'user'}:null;

function activityPublic(a){
 if(!a)return null;
 return {id:a.id,partyId:a.partyId,type:a.type,status:a.status,bossName:a.bossName,bossHp:a.bossHp,bossMax:a.bossMax,phase:a.phase,
   members:a.members.map(u=>{let p=alivePresence(u)||{};return {user:u,character:p.character||u,lv:p.lv||1,classId:p.classId||'adventurer',damage:a.damage[u]||0}}),
   log:a.log.slice(-20),startedAt:a.startedAt,wonAt:a.wonAt||null}
}
function finishActivity(a){
 if(a.status!=='active')return;a.status='won';a.wonAt=now();a.log.push('✓ Boss besiegt — Gruppenbelohnungen verteilt.');
 for(const u of a.members){
   let dmg=a.damage[u]||0,participated=dmg>0;
   reward(u,{xp:a.type==='raid'?260:180,jxp:a.type==='raid'?290:190,rep:a.type==='raid'?45:30,gold:a.type==='raid'?240:160,
     eventTokens:a.type==='event'?12:0,message:(a.type==='raid'?'Raid':'Event')+' abgeschlossen'+(participated?' · Beitrag '+dmg:'')});
 }
 save()
}
function cleanup(){
 for(const [u,p] of Object.entries(db.presence))if(now()-p.updated>60000)delete db.presence[u];
 for(const [k,a] of Object.entries(db.activities))if(a.status!=='active'&&now()-(a.wonAt||a.startedAt)>3600000)delete db.activities[k]
}

async function api(req,res,url){
 if(req.method==='OPTIONS'){res.writeHead(204,{'Access-Control-Allow-Origin':'*','Access-Control-Allow-Headers':'Content-Type,Authorization'});return res.end()}
 if(url.pathname==='/api/health')return json(res,200,{ok:true,version:'23.28'});
 let u=user(req);
 if(url.pathname==='/api/register'&&req.method==='POST'){let b=await body(req),name=String(b.username||'').trim().slice(0,24);if(!name||db.users[name])return json(res,400,{error:'user'});db.users[name]={password:String(b.password||''),role:'user',save:null};let t=id('tok');db.sessions[t]=name;save();return json(res,200,{token:t})}
 if(url.pathname==='/api/login'&&req.method==='POST'){let b=await body(req),x=db.users[b.username];if(!x||x.password!==String(b.password||''))return json(res,401,{error:'login'});let t=id('tok');db.sessions[t]=b.username;return json(res,200,{token:t,role:x.role||'user'})}
 if(!u)return json(res,401,{error:'auth'});
 if(url.pathname==='/api/save'&&req.method==='GET')return json(res,200,{data:db.users[u].save});
 if(url.pathname==='/api/save'&&req.method==='POST'){let b=await body(req);db.users[u].save=b.data;save();return json(res,200,{ok:true})}
 if(url.pathname==='/api/presence'&&req.method==='POST'){let b=await body(req);db.presence[u]={...b,user:u,role:db.users[u].role||b.role||'user',updated:now()};return json(res,200,{ok:true})}
 if(url.pathname==='/api/players'){cleanup();return json(res,200,{players:Object.values(db.presence).filter(p=>p.user!==u&&now()-p.updated<12000)})}
 if(url.pathname==='/api/party'&&req.method==='GET'){let p=partyOf(u);return json(res,200,{party:p||null,invite:db.invites[u]||null})}
 if(url.pathname==='/api/party/create'&&req.method==='POST'){if(partyOf(u))return json(res,409,{error:'party'});let p={id:id('party'),leader:u,members:[u],createdAt:now()};db.parties[p.id]=p;save();return json(res,200,{party:p})}
 if(url.pathname==='/api/party/invite'&&req.method==='POST'){let p=partyOf(u),b=await body(req),v=String(b.username||'');if(!p||p.leader!==u||!db.users[v]||p.members.length>=5)return json(res,400,{error:'invite'});db.invites[v]={from:u,partyId:p.id,at:now()};save();return json(res,200,{ok:true})}
 if(url.pathname==='/api/party/accept'&&req.method==='POST'){let inv=db.invites[u],p=inv&&db.parties[inv.partyId];if(!p||p.members.length>=5)return json(res,400,{error:'invite'});if(!p.members.includes(u))p.members.push(u);delete db.invites[u];save();return json(res,200,{party:p})}
 if(url.pathname==='/api/party/leave'&&req.method==='POST'){let p=partyOf(u);if(p){p.members=p.members.filter(x=>x!==u);if(!p.members.length)delete db.parties[p.id];else if(p.leader===u)p.leader=p.members[0]}save();return json(res,200,{ok:true})}
 if(url.pathname==='/api/party/reward'&&req.method==='POST'){
   let p=partyOf(u),b=await body(req);if(!p)return json(res,400,{error:'party'});
   let eligible=sameMapEligible(p,b.map,Number(b.x),Number(b.y),900);if(!eligible.length)eligible=[u];
   let bonus=Math.min(.25,.05+(eligible.length-1)*.05),n=eligible.length;
   for(const m of eligible){reward(m,{xp:Math.max(1,Math.round((Number(b.xp)||0)*(1+bonus)/n)),jxp:Math.max(1,Math.round((Number(b.jxp)||0)*(1+bonus)/n)),rep:Math.max(0,Math.round((Number(b.rep)||0)*(1+bonus)/n)),message:'Gruppen-EXP geteilt'})}
   save();return json(res,200,{ok:true,shared:n,bonus})
 }
 if(url.pathname==='/api/party/farm'&&req.method==='POST'){
   let p=partyOf(u),b=await body(req);if(!p)return json(res,400,{error:'party'});
   let eligible=sameMapEligible(p,b.map,Number(b.x),Number(b.y),900),bonus=Math.min(.25,.05+(eligible.length-1)*.05);
   if(eligible.length>1){for(const m of eligible){let items=[];if(Math.random()<(b.boss?.8:b.elite||b.champion?.42:.16))items.push({id:'party_material',name:b.boss?'Boss-Essenz':'Gruppen-Material',type:'material',icon:'ore_icon',power:0,qty:1});reward(m,{gold:Math.round((b.boss?80:8)*(1+bonus)),items,message:'Farmbeute geteilt'})}save()}
   return json(res,200,{shared:eligible.length,bonus})
 }
 if(url.pathname==='/api/party/rewards'&&req.method==='GET'){let r=db.rewards[u]||[];db.rewards[u]=[];save();return json(res,200,{rewards:r})}
 if(url.pathname==='/api/party/activity/start'&&req.method==='POST'){
   let p=partyOf(u),b=await body(req);if(!p)return json(res,400,{error:'party'});if(p.leader!==u)return json(res,403,{error:'leader'});
   let old=Object.values(db.activities).find(a=>a.partyId===p.id&&a.status==='active');if(old)return json(res,200,{activity:activityPublic(old)});
   let type=b.type==='event'?'event':'raid',members=p.members.filter(x=>alivePresence(x));if(!members.includes(u))members.push(u);
   let max=type==='raid'?5200:3900,a={id:id('act'),partyId:p.id,type,status:'active',bossName:type==='raid'?'Wurzelkönig':'Kürbisreaper',bossHp:max,bossMax:max,phase:1,members,damage:{},cooldowns:{},log:['Instanz gestartet. '+members.length+' Spieler verbunden.'],startedAt:now()};
   db.activities[a.id]=a;save();return json(res,200,{activity:activityPublic(a)})
 }
 if(url.pathname==='/api/party/activity'&&req.method==='GET'){let a=db.activities[url.searchParams.get('id')];if(!a||!a.members.includes(u))return json(res,404,{error:'activity'});return json(res,200,{activity:activityPublic(a)})}
 if(url.pathname==='/api/party/activity/action'&&req.method==='POST'){
   let b=await body(req),a=db.activities[b.activityId];if(!a||a.status!=='active'||!a.members.includes(u))return json(res,400,{error:'activity'});
   let cd=a.cooldowns[u]||{},t=now(),action=['attack','skill','heal'].includes(b.action)?b.action:'attack',wait=action==='skill'?1450:action==='heal'?4000:650;
   if((cd[action]||0)>t)return json(res,429,{error:'cooldown',retry:(cd[action]-t)});cd[action]=t+wait;a.cooldowns[u]=cd;
   if(action==='heal'){a.log.push((alivePresence(u)?.character||u)+' stärkt die Gruppe.');}
   else{let power=clamp(Number(b.power)||10,5,500),mult=action==='skill'?1.9:1,dmg=Math.round((22+power*.72)*mult*(.88+Math.random()*.24));a.bossHp=Math.max(0,a.bossHp-dmg);a.damage[u]=(a.damage[u]||0)+dmg;a.log.push((alivePresence(u)?.character||u)+' '+(action==='skill'?'Skill':'Angriff')+' → '+dmg+' Schaden.');a.phase=a.bossHp/a.bossMax<=.34?3:a.bossHp/a.bossMax<=.67?2:1}
   if(a.bossHp<=0)finishActivity(a);else save();return json(res,200,{activity:activityPublic(a)})
 }
 if(url.pathname==='/api/admin/role'&&req.method==='POST'){if((db.users[u].role||'user')!=='admin')return json(res,403,{error:'admin'});let b=await body(req);if(!db.users[b.user])return json(res,404,{error:'user'});db.users[b.user].role=['user','mod','admin'].includes(b.role)?b.role:'user';save();return json(res,200,{ok:true})}
 return json(res,404,{error:'route'})
}

const server=http.createServer(async(req,res)=>{
 try{
   let url=new URL(req.url,'http://localhost');
   if(url.pathname.startsWith('/api/'))return await api(req,res,url);
   let file=url.pathname==='/'?path.join(ROOT,'bramble_v23_28_combat_depth_loot_flow.html'):path.join(ROOT,path.basename(url.pathname));
   if(!file.startsWith(ROOT)||!fs.existsSync(file))return json(res,404,{error:'not found'});
   res.writeHead(200,{'Content-Type':file.endsWith('.html')?'text/html; charset=utf-8':'application/octet-stream'});fs.createReadStream(file).pipe(res)
 }catch(e){console.error(e);json(res,500,{error:'server'})}
});
server.listen(PORT,'0.0.0.0',()=>console.log(`BRAMBLE V23.24 server: http://localhost:${PORT}\nLAN: open http://<PC-IP>:${PORT} on each device`));
setInterval(cleanup,10000);
