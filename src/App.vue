<template>
	<div id="app">
		<a href="#general">general</a> | <a href="#random">random</a>
		<form @submit.prevent="submit">
			<input v-model="id" placeholder="id" value="id">
			<input type="submit">
		</form> 

		<p v-if="latest">202004 - {{ latest.latest.slice(0,6) }}</p>

		<div v-if="items">
			<h3 id="general">general</h3>
			<li v-for="i in items.messages">
				<span class="time">{{ moment(i.ts) }}</span>
				<span class="name">{{ i.user }}</span>
				{{ i.text }}
			</li>
			<div v-if="items.response_metadata">
				<li v-for="i in items_n.messages">
					<span class="time">{{ moment(i.ts) }}</span>
					<span class="name">{{ i.user }}</span>
					{{ i.text }}
				</li>
			</div>
		</div>

		<div v-if="itemsr">
			<h3 id="random">random</h3>
			<li v-for="i in itemsr.messages">
				<span class="time">{{ moment(i.ts) }}</span>
				<span class="name">{{ i.user }}</span>
				{{ i.text }}
			</li>
			<div v-if="itemsr.response_metadata">
				<li v-for="i in items_nr.messages">
					<span class="time">{{ moment(i.ts) }}</span>
					<span class="name">{{ i.user }}</span>
					{{ i.text }}
				</li>
				<div v-if="items_nr.response_metadata">
					<li v-for="i in items_san.messages">
						<span class="time">{{ moment(i.ts) }}</span>
						<span class="name">{{ i.user }}</span>
						{{ i.text }}
					</li>
				</div>
			</div>
		</div>

	</div>
</template>

<script>
import axios from 'axios'
import moment from 'moment';
export default {
	data() {
		return {
			message: null,
			latest: null,
			id: 202005,
			items: null,
			itemsr: null,
		}
	},
	mounted() {
		axios
			.get("https://raw.githubusercontent.com/ArchLinuxJP/slacklog/master/json/20200501_general.json")
			.then(a => { 
				this.items = a.data;
			})
			.catch()
			.finally();
			axios
				.get("https://raw.githubusercontent.com/ArchLinuxJP/slacklog/master/json/latest.json")
				.then(b => { 
					this.latest = b.data;
				})
				.catch()
				.finally();
	},
	methods: {
		moment: function (date) {
			return moment.unix(date).format('YYYY/MM/DD HH:mm:SS')
		},
		submit() {
			this.url = "https://raw.githubusercontent.com/ArchLinuxJP/slacklog/master/json/" + this.id + "01_general.json"
			axios
				.get(this.url)
				.then(response => { 
					this.items = response.data;
				})
				.catch(response => { 
					this.items = null;
				})
				.finally();
				this.urlr = "https://raw.githubusercontent.com/ArchLinuxJP/slacklog/master/json/" + this.id + "01_random.json"
				axios
					.get(this.urlr)
					.then(response => { 
						this.itemsr = response.data;
					})
					.catch(response => { 
						this.itemsr = null;
					})
					.finally();
					this.url = "https://raw.githubusercontent.com/ArchLinuxJP/slacklog/master/json/" + this.id + "01_general-2.json"
					axios
						.get(this.url)
						.then(response => { 
							this.items_n = response.data;
						})
						.catch(response => { 
							this.items_n = null;
						})
						.finally();
						this.url = "https://raw.githubusercontent.com/ArchLinuxJP/slacklog/master/json/" + this.id + "01_random-2.json"
						axios
							.get(this.url)
							.then(response => { 
								this.items_nr = response.data;
							})
							.catch(response => { 
								this.items_nr = null;
							})
							.finally();
							this.url = "https://raw.githubusercontent.com/ArchLinuxJP/slacklog/master/json/" + this.id + "01_random-3.json"
							axios
								.get(this.url)
								.then(response => { 
									this.items_san = response.data;
								})
								.catch(response => { 
									this.items_san = null;
								})
								.finally();
		}
	}
}
</script>

<style>
span.time {
	color: red;
	padding-left:5px;
}
span.name {
	color: blue;
	padding-left:5px;
}
</style>
