import { staticDirective } from './directives'
import { staticMixin } from './mixins'

export default {
  install(Vue, options) {
    Vue.directive('static', staticDirective)
    Vue.mixin(staticMixin)
  }
}
