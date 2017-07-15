import Card from './Card.vue'
import JumboTron from './JumboTron.vue'
import TopNav from './TopNav.vue'

const components = {
  JumboTron,
  TopNav,
  Card
}

/* eslint-disable no-var, no-undef, guard-for-in, object-shorthand */
const VuePlugin = {
    install: function (Vue) {
        if (Vue._custom_components_installed) {
            return
        }

        Vue._custom_components_installed = true;

        // Register components
        for (var component in components) {
            Vue.component(component, components[component])
        }
    }
}

export default VuePlugin
