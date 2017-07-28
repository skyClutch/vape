<template>
  <div class="row">
    <jumbo-tron :title="title"></jumbo-tron>
    <card v-for="(link, idx) in links" :key="link.id"
      v-bind:idx="idx"
      v-bind:url="link.url"
      v-bind:title="link.title"
      v-bind:text="link.text"
      v-static="{ '.snippet': 'text', '.card-title': 'title', ctx: link }"
    ></card>
  </div>
</template>

<script>
  export default {
    name: 'programs',
    data: () => ({
      title: 'Programs',
      links: [
        {
          text: 'change me',
          title: 'Family Engagement',
          url: 'http://www.pta.org/programs/content.cfm?ItemNumber=4624'
        },
        {
          text: 'change me',
          title: 'Family Reading Experience',
          url: 'http://www.pta.org/programs/familyreading.cfm?ItemNumber=4733&navItemNumber=4765'
        },
        {
          text: 'change me',
          title: 'Connect for Respect',
          url: 'http://www.pta.org/programs/content.cfm?ItemNumber=3003&navItemNumber=3984'
        },
        {
          text: 'change me',
          title: 'Healthy Lifestyles',
          url: 'http://www.pta.org/programs/content.cfm?ItemNumber=4280&navItemNumber=4216'
        },
        {
          text: 'change me',
          title: 'Safety At Home And At Play / Safety Toolkit',
          url: 'http://www.pta.org/programs/content.cfm?ItemNumber=3789&navItemNumber=4631'
        },
        {
          text: 'change me',
          title: 'Take Your Family to School Week',
          url: 'http://www.pta.org/programs/familytoschool.cfm?ItemNumber=3262&navItemNumber=5106'
        },
        {
          text: 'change me',
          title: 'Healthy Habits',
          url: 'http://www.pta.org/programs/content.cfm?ItemNumber=3792'
        },
        {
          text: 'change me',
          title: 'Smart Talk',
          url: 'https://thesmarttalk.org/#/'
        },
        {
          text: 'change me',
          title: 'Multi-Cultural Event',
          url: 'http://s3.amazonaws.com/rdcms-pta/files/production/public/TYFTSW_Guide_MulticulturalGuide-2016.pdf'
        },
        {
          text: 'change me',
          title: 'Creative Career Fair Guide',
          url: 'http://s3.amazonaws.com/rdcms-pta/files/production/public/TYFTSW_Guide_CreativeCareer-2016.pdf'
        },
        {
          text: 'change me',
          title: 'Elevate (Math)',
          url: 'http://capta.org/programs-events/elevate-math/'
        },
        {
          text: 'change me',
          title: 'Military Alliance (Helping Military Families Integrate',
          url: 'http://www.pta.org/parents/content.cfm?ItemNumber=3616'
        },
        {
          text: 'change me',
          title: 'PTA Three for Me',
          url: 'http://www.pta.org/programs/content.cfm?ItemNumber=3274'
        },
      ]
    })
  }
</script>
