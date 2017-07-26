insert into pta_dist_14.page (author_id, route, title, template, data, parent_id) values
  (1, 'home', 'Home', $$  <div class="row">    <card v-for="(page, idx) in $store.state.page.data.children" :key="page.id"      v-bind:path="page.data.route"      v-bind:text="page.data.body"      v-bind:img="page.data.img"      v-bind:title="page.data.title"      v-bind:sub-title="page.data.subTitle"      v-bind:idx="idx"    ></card>  </div>$$, '{"title":"Home","body":"here have some text"}', null),
  (1, 'about', 'About', $$  <div class="row">    <card v-for="(page, idx) in $store.state.page.data.children" :key="page.id"      v-bind:path="page.data.route"      v-bind:text="page.data.body"      v-bind:img="page.data.img"      v-bind:title="page.data.title"      v-bind:sub-title="page.data.subTitle"      v-bind:idx="idx"    ></card>  </div>$$, '{"title":"About","body":"here have some text"}', null),
  (1, 'board', 'Board', $$  <div>     <jumbo-tron :title="title" :img="img"></jumbo-tron>    <div class="backdrop" v-html="body"> </div>    </div>$$, '{"parentId":2,"title":"Board","img":"http://thecatapi.com/api/images/get?format=src&type=gif&size=med","body":"<ul> \n      <li>Abby Fellman - President </li>\n      <li>Michelle Wing - Treasurer</li>\n      <li>Elizabeth Smith- Secretary/ Membership/ Historian</li>\n      <li>Trish Luna - Leadership VP/ Coast Area Coordinator</li>\n      <li>Christal Barquero- Programming VP / Reflections / Santa Rosa & North Area Coordinator</li>\n      <li>Nicole Turner - Rohnert Park / Cotati Area Coordinato</li>\n      <li>Samantha Bolinger - Petaluma Area Coordinator</li>\n      </ul>"}', 2),
  (1, 'forms', 'Forms', $$  <div class="row">    <card v-for="(link, idx) in links" :key="link.id"          :idx="idx"          :url="link.path"          :title="link.title"          :text="link.text"          :links="links"          ></card>  </div>$$, '{"title":"Forms","links":[{"type":"pdf","title":"2017 Insurance Loss Guide English","path":"/public/forms/2017-Insurance-Loss-Guide-English.pdf","text":"replace me"},{"type":"docx","title":"3 DPBank Letterafterdisband","path":"/public/forms/3_DPBank Letterafterdisband.docx","text":"replace me"},{"type":"pdf","title":"ALT COS","path":"/public/forms/ALT-COS.pdf","text":"replace me"},{"type":"pdf","title":"Annual Workers Comp 2016","path":"/public/forms/Annual Workers Comp 2016.pdf","text":"replace me"},{"type":"pdf","title":"BylawsReviewSummary2015 docx","path":"/public/forms/BylawsReviewSummary2015.docx.pdf","text":"replace me"},{"type":"doc","title":"Bylaws Submittal Form   Units","path":"/public/forms/Bylaws_Submittal Form - Units.doc","text":"replace me"},{"type":"docx","title":"Certificate of Incumbency","path":"/public/forms/Certificate of Incumbency.docx","text":"replace me"},{"type":"pdf","title":"ChangeOfStatus  fillable copy","path":"/public/forms/ChangeOfStatus--fillable copy.pdf","text":"replace me"},{"type":"doc","title":"G1 MembershipEnvelopeOrderFormFILLABLE","path":"/public/forms/G1-MembershipEnvelopeOrderFormFILLABLE.doc","text":"replace me"},{"type":"pdf","title":"PTA UNIT BANK INFORMATION FORM","path":"/public/forms/PTA UNIT BANK INFORMATION FORM.pdf","text":"replace me"},{"type":"pdf","title":"RequestForAdvancePaymentAuthorization","path":"/public/forms/RequestForAdvancePaymentAuthorization.pdf","text":"replace me"},{"type":"pdf","title":"Unit Remittance Form 2017 late Ins","path":"/public/forms/Unit Remittance Form-2017 late Ins.pdf","text":"replace me"},{"type":"pdf","title":"Unit Bylaws ES ICU FILLABLE2016","path":"/public/forms/Unit_Bylaws_ES_ICU_FILLABLE2016.pdf","text":"replace me"},{"type":"pdf","title":"Unit Bylaws ES OOC FILLABLE2016","path":"/public/forms/Unit_Bylaws_ES_OOC_FILLABLE2016.pdf","text":"replace me"},{"type":"pdf","title":"Unit Bylaws ICU FILLABLE2016","path":"/public/forms/Unit_Bylaws_ICU_FILLABLE2016.pdf","text":"replace me"},{"type":"pdf","title":"Unit Bylaws OOC FILLABLE2016","path":"/public/forms/Unit_Bylaws_OOC_FILLABLE2016.pdf","text":"replace me"},{"type":"pdf","title":"WorkersCompAnnualPayroll","path":"/public/forms/WorkersCompAnnualPayroll.pdf","text":"replace me"},{"type":"pdf","title":"auditchecklist","path":"/public/forms/auditchecklist.pdf","text":"replace me"},{"type":"pdf","title":"auditreport2016updated","path":"/public/forms/auditreport2016updated.pdf","text":"replace me"},{"type":"pdf","title":"cashverification2016updated","path":"/public/forms/cashverification2016updated.pdf","text":"replace me"},{"type":"pdf","title":"reimbursement","path":"/public/forms/reimbursement.pdf","text":"replace me"},{"type":"pdf","title":"volunteerhours","path":"/public/forms/volunteerhours.pdf","text":"replace me"}]}', null),
  (1, 'join', 'Join Our Team', $$  <div>     <jumbo-tron :title="title" :img="img"></jumbo-tron>    <div class="backdrop" v-html="body"></div>   </div>$$, '{"parentId":2,"title":"Join Our Team","img":"http://thecatapi.com/api/images/get?format=src&type=gif&size=med","body":"We need new board members for these positions: <ul> <li>Santa Rosa & North Area Coordinator</li> <li>Diversity & Inclusion VP</li> <li>Student Board Member</li> <li>Communications VP</li> </ul>"}', 2),
  (1, 'mission-statement', 'Mission Statement', $$  <div>     <jumbo-tron :title="title" :img="img"></jumbo-tron>    <div class="backdrop" v-html="body"></div>  </div>$$, '{"parentId":2,"title":"Mission Statement","img":"http://thecatapi.com/api/images/get?format=src&type=gif&size=med","body":"The mission of the 14th district is to improve the education, health, and well being of the children and families and Sonoma, Mendocino, and Lake County by advocating for cultivating and empowering units."}', 2),
  (1, 'programs', 'Programs', $$  <div class="row">    <card v-for="(link, idx) in links" :key="link.id"      v-bind:idx="idx"      v-bind:url="link.url"      v-bind:title="link.title"      v-bind:text="link.text"      v-static="{ '.snippet': 'text', '.card-title': 'title', ctx: link }"    ></card>  </div>$$, '{"title":"Programs","links":[{"text":"change me","title":"Family Engagement","url":"http://www.pta.org/programs/content.cfm?ItemNumber=4624"},{"text":"change me","title":"Family Reading Experience","url":"http://www.pta.org/programs/familyreading.cfm?ItemNumber=4733&navItemNumber=4765"},{"text":"change me","title":"Connect for Respect","url":"http://www.pta.org/programs/content.cfm?ItemNumber=3003&navItemNumber=3984"},{"text":"change me","title":"Healthy Lifestyles","url":"http://www.pta.org/programs/content.cfm?ItemNumber=4280&navItemNumber=4216"},{"text":"change me","title":"Safety At Home And At Play / Safety Toolkit","url":"http://www.pta.org/programs/content.cfm?ItemNumber=3789&navItemNumber=4631"},{"text":"change me","title":"Take Your Family to School Week","url":"http://www.pta.org/programs/familytoschool.cfm?ItemNumber=3262&navItemNumber=5106"},{"text":"change me","title":"Healthy Habits","url":"http://www.pta.org/programs/content.cfm?ItemNumber=3792"},{"text":"change me","title":"Smart Talk","url":"https://thesmarttalk.org/#/"},{"text":"change me","title":"Multi-Cultural Event","url":"http://s3.amazonaws.com/rdcms-pta/files/production/public/TYFTSW_Guide_MulticulturalGuide-2016.pdf"},{"text":"change me","title":"Creative Career Fair Guide","url":"http://s3.amazonaws.com/rdcms-pta/files/production/public/TYFTSW_Guide_CreativeCareer-2016.pdf"},{"text":"change me","title":"Elevate (Math)","url":"http://capta.org/programs-events/elevate-math/"},{"text":"change me","title":"Military Alliance (Helping Military Families Integrate","url":"http://www.pta.org/parents/content.cfm?ItemNumber=3616"},{"text":"change me","title":"PTA Three for Me","url":"http://www.pta.org/programs/content.cfm?ItemNumber=3274"}]}', null),
  (1, 'units', 'Our Units', $$  <div>     <jumbo-tron :title="title" :img="img"></jumbo-tron>    <div class="backdrop" v-html="body"></div>  </div>$$, '{"parentId":2,"title":"Our Units","img":"http://thecatapi.com/api/images/get?format=src&type=gif&size=med","body":"Here, have some units!"}', 2),
  (1, 'welcome', 'Welcome', $$  <div class="row">     <jumbo-tron :title="title" :img="img"></jumbo-tron>    <div class="backdrop">      <p>{{body}}</p>    </div>  </div>$$, '{"parentId":1,"title":"Welcome","img":"/public/balloon.jpg","body":"The 14th District PTA serves Sonoma, Mendocino, and Lake counties. We are comprised of 45 school PTAs and have over 5,000 members. Our members are parents, administrators, teachers, students, and community members..."}', 1)