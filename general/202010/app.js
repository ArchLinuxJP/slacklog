var app = new Vue({
    el: '#app',
    data: {
    cities: []
    },
    methods: {
        async getCities() {
        var url = 'https://raw.githubusercontent.com/archlinuxjp/slacklog/master/202010-general.json'
        await axios.get(url).then(x => { this.cities = x.data })
        }
    },
    mounted() {
        this.getCities()
    }
})
