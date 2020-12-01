Vue.use(VueMarkdown);
var app = new Vue({
 el: '#app',
 data: {
	cities: [],
	markdownText: ''
 },
 methods: {
	async getCities() {
	 var url = 'https://raw.githubusercontent.com/archlinuxjp/slacklog/master/202012-random.json'
	 await axios.get(url).then(x => { this.cities = x.data })
	}
 },
 mounted() {
	this.getCities();
 },
 computed: {
	dirname() {
	 var currentUrl = window.location.pathname.split('/')[3];
	 //var currentUrl = "202010";
	 return currentUrl;
	},
	compiledMarkdown() {
	 return marked(this.markdownText);
	}
 }
})
