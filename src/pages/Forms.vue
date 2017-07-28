<template>
  <div class="row">
    <jumbo-tron :title="title"></jumbo-tron>
    <card v-for="(link, idx) in links" :key="link.id"
      v-bind:idx="idx"
      v-bind:url="link.path"
      v-bind:title="link.title"
      v-bind:text="link.text"
      v-static="{ '.snippet': 'text', '.card-title': 'title', ctx: link }"
    ></card>
  </div>
</template>

<script>
export default {
  name: 'forms',
  data: () => ({
    title: 'Forms',
    links: [
      {
        "type": "pdf",
        "title": "2017 Insurance Loss Guide English",
        "path": "/public/forms/2017-Insurance-Loss-Guide-English.pdf",
        "text": "replace me"
      },
      {
        "type": "docx",
        "title": "3 DPBank Letterafterdisband",
        "path": "/public/forms/3_DPBank Letterafterdisband.docx",
        "text": "replace me"
      },
      {
        "type": "pdf",
        "title": "ALT COS",
        "path": "/public/forms/ALT-COS.pdf",
        "text": "replace me"
      },
      {
        "type": "pdf",
        "title": "Annual Workers Comp 2016",
        "path": "/public/forms/Annual Workers Comp 2016.pdf",
        "text": "replace me"
      },
      {
        "type": "pdf",
        "title": "BylawsReviewSummary2015 docx",
        "path": "/public/forms/BylawsReviewSummary2015.docx.pdf",
        "text": "replace me"
      },
      {
        "type": "doc",
        "title": "Bylaws Submittal Form   Units",
        "path": "/public/forms/Bylaws_Submittal Form - Units.doc",
        "text": "replace me"
      },
      {
        "type": "docx",
        "title": "Certificate of Incumbency",
        "path": "/public/forms/Certificate of Incumbency.docx",
        "text": "replace me"
      },
      {
        "type": "pdf",
        "title": "ChangeOfStatus  fillable copy",
        "path": "/public/forms/ChangeOfStatus--fillable copy.pdf",
        "text": "replace me"
      },
      {
        "type": "doc",
        "title": "G1 MembershipEnvelopeOrderFormFILLABLE",
        "path": "/public/forms/G1-MembershipEnvelopeOrderFormFILLABLE.doc",
        "text": "replace me"
      },
      {
        "type": "pdf",
        "title": "PTA UNIT BANK INFORMATION FORM",
        "path": "/public/forms/PTA UNIT BANK INFORMATION FORM.pdf",
        "text": "replace me"
      },
      {
        "type": "pdf",
        "title": "RequestForAdvancePaymentAuthorization",
        "path": "/public/forms/RequestForAdvancePaymentAuthorization.pdf",
        "text": "replace me"
      },
      {
        "type": "pdf",
        "title": "Unit Remittance Form 2017 late Ins",
        "path": "/public/forms/Unit Remittance Form-2017 late Ins.pdf",
        "text": "replace me"
      },
      {
        "type": "pdf",
        "title": "Unit Bylaws ES ICU FILLABLE2016",
        "path": "/public/forms/Unit_Bylaws_ES_ICU_FILLABLE2016.pdf",
        "text": "replace me"
      },
      {
        "type": "pdf",
        "title": "Unit Bylaws ES OOC FILLABLE2016",
        "path": "/public/forms/Unit_Bylaws_ES_OOC_FILLABLE2016.pdf",
        "text": "replace me"
      },
      {
        "type": "pdf",
        "title": "Unit Bylaws ICU FILLABLE2016",
        "path": "/public/forms/Unit_Bylaws_ICU_FILLABLE2016.pdf",
        "text": "replace me"
      },
      {
        "type": "pdf",
        "title": "Unit Bylaws OOC FILLABLE2016",
        "path": "/public/forms/Unit_Bylaws_OOC_FILLABLE2016.pdf",
        "text": "replace me"
      },
      {
        "type": "pdf",
        "title": "WorkersCompAnnualPayroll",
        "path": "/public/forms/WorkersCompAnnualPayroll.pdf",
        "text": "replace me"
      },
      {
        "type": "pdf",
        "title": "auditchecklist",
        "path": "/public/forms/auditchecklist.pdf",
        "text": "replace me"
      },
      {
        "type": "pdf",
        "title": "auditreport2016updated",
        "path": "/public/forms/auditreport2016updated.pdf",
        "text": "replace me"
      },
      {
        "type": "pdf",
        "title": "cashverification2016updated",
        "path": "/public/forms/cashverification2016updated.pdf",
        "text": "replace me"
      },
      {
        "type": "pdf",
        "title": "reimbursement",
        "path": "/public/forms/reimbursement.pdf",
        "text": "replace me"
      },
      {
        "type": "pdf",
        "title": "volunteerhours",
        "path": "/public/forms/volunteerhours.pdf",
        "text": "replace me"
      }
    ]
  })
}
</script>


