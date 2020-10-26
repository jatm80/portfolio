define(function(require) {
	var $ = require('jquery'),
		_ = require('lodash'),
		monster = require('monster');

	var app = {
		name: 'recordings',

		css: [ 'app' ],

		i18n: {
			'en-US': { customCss: false }
		},

		appFlags: {
			recordings: {
				maxRange: 31,
				defaultRange: 1,
				minPhoneNumberLength: 7
			}
		},

		requests: {},
		subscribe: {},

		load: function(callback) {
			var self = this;

			self.initApp(function() {
				callback && callback(self);
			});
		},

		initApp: function(callback) {
			var self = this;

			monster.pub('auth.initApp', {
				app: self,
				callback: callback
			});
		},

		render: function(container) {
			var self = this;

			self.getRecordingsData(function(results) {
				var menus = [
					{
						tabs: [
							{
								text: self.i18n.active().recordings.menuTitles.receivedRecs,
								callback: self.renderReceivedRecs
							}
						]
					}
				];

				// if (results.storage) {
				// 	var tabStorage = {
				// 		text: self.i18n.active().recordings.menuTitles.storage,
				// 		callback: self.renderStorage
				// 	};

				// 	menus[0].tabs.push(tabStorage);
				// }

				monster.ui.generateAppLayout(self, {
					menus: menus
				});
			});
		},

		getRecordingsData: function(callback) {
			var self = this;

			monster.parallel({
				storage: function(callback) {
					self.getStorage(function(storage) {
						callback(null, storage);
					});
				}
			},
			function(err, results) {
				callback && callback(results);
			});
		},

		getStorage: function(callback) {
			var self = this;

			self.callApi({
				resource: 'storage.get',
				data: {
					accountId: self.accountId,
					generateError: false
				},
				success: function(data) {
					callback(data.data);
				},
				error: function(data, error, globalHandler) {
					if (error.status === 404) {
						callback(undefined);
					} else {
						globalHandler(data);
					}
				}
			});
		},

		renderStorage: function(pArgs) {
			var self = this,
				args = pArgs || {},
				parent = args.container || $('#recordings_app_container .app-content-wrapper');

			self.getStorage(function(storage) {
				var formattedData = self.storageFormatData(storage),
					template = $(self.getTemplate({
						name: 'storage',
						data: formattedData
					}));

				self.storageBindEvents(template);

				monster.pub('common.storagePlanManager.render', {
					container: template.find('.control-container'),
					forceTypes: ['mailbox_message'],
					hideOtherTypes: true
				});

				parent
					.fadeOut(function() {
						$(this)
							.empty()
							.append(template)
							.fadeIn();
					});
			});
		},

		storageBindEvents: function(template) {
			var self = this;
		},

		storageFormatData: function(data) {
			return data;
		},

		//JT
		renderReceivedRecs: function(pArgs) {
			var self = this,
				args = pArgs || {},
				parent = args.container || $('#recordings_app_container .app-content-wrapper');

			self.listRecordingInit(function (template) {
				    template = $(self.getTemplate({
						name: 'received-recordings'
					}));

				self.recordingsInitDatePicker(parent, template);

				self.bindreceivedRecs(template);

				self.displayList(template);

				parent
					.fadeOut(function() {
						$(this)
							.empty()
							.append(template)
							.fadeIn();
					});
			});
		},

		recordingsInitDatePicker: function(parent, template) {
			var self = this,
				dates = monster.util.getDefaultRangeDates(self.appFlags.recordings.defaultRange),
				fromDate = dates.from,
				toDate = dates.to;

			var optionsDatePicker = {
				container: template,
				range: self.appFlags.recordings.maxRange
			};

			monster.ui.initRangeDatepicker(optionsDatePicker);

			template.find('#startDate').datepicker('setDate', fromDate);
			template.find('#endDate').datepicker('setDate', toDate);

			template.find('.apply-filter').on('click', function(e) {
				var vmboxId = template.find('#select_vmbox').val();

				self.displayList(parent);
			});

			template.find('.toggle-filter').on('click', function() {
				template.find('.filter-by-date').toggleClass('active');
			});
		},

		bindreceivedRecs: function(template) {
			var self = this;

			monster.ui.tooltips(template);
			monster.ui.footable(template.find('.footable'));

			template.find('.delete-recordings').on('click', function() {
				var rows = template.find('.select-message:checked'),
				rows = [];

				$rows.each(function() {
					rows.push($(this).data('media-id'));
				});

				template.find('.data-state')
						.hide();

				template.find('.loading-state')
						.show();

				self.bulkRemoveRecordings(rows, function() {
					self.displayList(template);
				});
			});

			template.on('click', '.play-vm', function(e) {
				var $row = $(this).parents('.recordings-row'),
					$activeRows = template.find('.recordings-row.active');

				if (!$row.hasClass('active') && $activeRows.length !== 0) {
					return;
				}

				e.stopPropagation();

				var mediaId = $row.data('media-id');

				template.find('table').addClass('highlighted');
				$row.addClass('active');

				self.playRecording(template, mediaId);
			});

			template.on('click', '.details-vm', function() {
				var $row = $(this).parents('.recordings-row'),
					callId = $row.data('call-id');

				self.getCDR(callId, function(cdr) {
					var template = $(self.getTemplate({
						name: 'recording-CDRDialog'
					}));

					monster.ui.renderJSON(cdr, template.find('#jsoneditor'));

					monster.ui.dialog(template, { title: self.i18n.active().recordings.receivedRecs.CDRPopup.title });
				}, function() {
					monster.ui.alert(self.i18n.active().recordings.receivedRecs.noCDR);
				});
			});

			var afterSelect = function() {
				if (template.find('.select-message:checked').length) {
					template.find('.hidable').removeClass('hidden');
					template.find('.main-select-message').prop('checked', true);
				} else {
					template.find('.hidable').addClass('hidden');
					template.find('.main-select-message').prop('checked', false);
				}
			};

			template.on('change', '.select-message', function() {
				afterSelect();
			});

			template.find('.main-select-message').on('click', function() {
				var $this = $(this),
					isChecked = $this.prop('checked');

				template.find('.select-message').prop('checked', isChecked);

				afterSelect();
			});

			template.find('.select-some-messages').on('click', function() {
				var $this = $(this),
					type = $this.data('type');

				template.find('.select-message').prop('checked', false);

				if (type !== 'none') {
					if (type === 'all') {
						template.find('.select-message').prop('checked', true);
					} else if (['new', 'saved', 'deleted'].indexOf(type) >= 0) {
						template.find('.recordings-row[data-folder="' + type + '"] .select-message').prop('checked', true);
					}
				}

				afterSelect();
			});

			template.on('click', '.select-line', function() {
				if (template.find('table').hasClass('highlighted')) {
					return;
				}

				var cb = $(this).parents('.recordings-row').find('.select-message');

				cb.prop('checked', !cb.prop('checked'));
				afterSelect();
			});
		},

		removeOpacityLayer: function(template, $activeRows) {
			$activeRows.find('.recording-player').remove();
			$activeRows.find('.duration, .actions').show();
			$activeRows.removeClass('active');
			template.find('table').removeClass('highlighted');
		},

		formatRecURI: function(mediaId) {
			var self = this;

			return self.apiUrl + 'accounts/' + self.accountId + '/recordings/' + mediaId + '?auth_token=' + self.getAuthToken() + '&accept=audio/mpeg';
		},

		playRecording: function(template, mediaId) {
			var self = this,
				$row = template.find('.recordings-row[data-media-id="' + mediaId + '"]');

			template.find('table').addClass('highlighted');
			$row.addClass('active');

			$row.find('.duration, .actions').hide();

			var uri = self.formatRecURI(mediaId),
				dataTemplate = {
					uri: uri
				},
				templateCell = $(self.getTemplate({
					name: 'cell-recording-player',
					data: dataTemplate
				}));

			$row.append(templateCell);

			var closePlayerOnClickOutside = function(e) {
					if ($(e.target).closest('.recording-player').length) {
						return;
					}
					e.stopPropagation();
					closePlayer();
				},
				closePlayer = function() {
					$(document).off('click', closePlayerOnClickOutside);
					self.removeOpacityLayer(template, $row);
				};

			$(document).on('click', closePlayerOnClickOutside);

			templateCell.find('.close-player').on('click', closePlayer);

			// Autoplay in JS. For some reason in HTML, we can't pause the stream properly for the first play.
			templateCell.find('audio').get(0).play();
		},

		recordingsGetRows: function(filters, callback) {
			var self = this;

			self.listRecordings(filters, function(data) {
				var formattedData = self.formatMessagesData(data),
					dataTemplate = {
						recordings: formattedData.recordings
					},
					$rows = $(self.getTemplate({
						name: 'recordings-rows',
						data: dataTemplate
					}));

				callback && callback($rows, data, formattedData);
			});
		},

		displayList: function(container) {
			var self = this,
				fromDate = container.find('input.filter-from').datepicker('getDate'),
				toDate = container.find('input.filter-to').datepicker('getDate'),
				filterByDate = container.find('.filter-by-date').hasClass('active');

			container.removeClass('empty');
			//container.find('.counts-wrapper').hide();
			container.find('.count-wrapper[data-type="new"] .count-text').html('?');
			container.find('.count-wrapper[data-type="total"] .count-text').html('?');

			// Gives a better feedback to the user if we empty it as we click... showing the user something is happening.
			container.find('.data-state')
						.hide();

			container.find('.loading-state')
						.show();

			container.find('.hidable').addClass('hidden');
			container.find('.main-select-message').prop('checked', false);

			monster.ui.footable(container.find('.recordings-table .footable'), {
				getData: function(filters, callback) {
					if (filterByDate) {
						filters = $.extend(true, filters, {
							created_from: monster.util.dateToBeginningOfGregorianDay(fromDate),
							created_to: monster.util.dateToEndOfGregorianDay(toDate)
						});
					}
					// we do this to keep context
					self.recordingsGetRows(filters, function($rows, data, formattedData) {
						container.find('.count-wrapper[data-type="new"] .count-text').html(formattedData.counts.newMessages);
						container.find('.count-wrapper[data-type="total"] .count-text').html(formattedData.counts.totalMessages);

						callback && callback($rows, data);
					});
				},
				afterInitialized: function() {
					container.find('.data-state')
								.show();

					container.find('.loading-state')
								.hide();
				},
				backendPagination: {
					enabled: false
				}
			});
		},

		formatMessagesData: function(recordings) {
			var self = this,
				tryFormatPhoneNumber = function(value) {
					var minPhoneNumberLength = self.appFlags.recordings.minPhoneNumberLength,
						prefixedPhoneNumber,
						formattedPhoneNumber;

					if (_.size(value) < minPhoneNumberLength) {
						return {
							isPhoneNumber: false,
							value: value,
							userFormat: value
						};
					}

					prefixedPhoneNumber = _.head(value) === '+'
						? value
						: /^\d+$/.test(value)	// Prepend '+' if there are only numbers
							? '+' + value
							: value;
					formattedPhoneNumber = monster.util.getFormatPhoneNumber(prefixedPhoneNumber);

					return {
						isPhoneNumber: formattedPhoneNumber.isValid,
						value: formattedPhoneNumber.isValid
							? formattedPhoneNumber.e164Number
							: value,
						userFormat: formattedPhoneNumber.isValid
							? formattedPhoneNumber.userFormat
							: value
					};
				},
				formattedRecordings = _.map(recordings, function(rc) {
					var to = rc.to.substr(0, rc.to.indexOf('@')),
						from = rc.from.substr(0, rc.from.indexOf('@')),
						callerIDName = _.get(rc, 'caller_id_name', ''),
						formattedTo = tryFormatPhoneNumber(to),
						formattedFrom = tryFormatPhoneNumber(from),
						formattedCallerIDName = tryFormatPhoneNumber(callerIDName);

					return _.merge({
						formatted: {
							to: formattedTo,
							from: formattedFrom,
							callerIDName: formattedCallerIDName,
							duration: monster.util.friendlyTimer(rc.duration_ms / 1000),
							direction: rc.direction == "outbound" ? "INBOUND" : "OUTBOUND",
							uri: self.formatRecURI(rc.id),
							callId: monster.util.getModbID(rc.call_id, rc.start),
							mediaId: rc.id,
							showCallerIDName: formattedCallerIDName.value !== formattedFrom.value
						}
					}, rc);
				}),
				formattedData = {
					recordings: formattedRecordings,
					counts: {
						newMessages: _.sumBy(recordings, function(rc) {
							return _
								.chain(rc)
								.get('folder')
								.isEqual('new')
								.toInteger()
								.value();
						}),
						totalMessages: recordings.length
					}
				};

			return formattedData;
		},

		getCDR: function(callId, callback, error) {
			var self = this;

			self.callApi({
				resource: 'cdrs.get',
				data: {
					accountId: self.accountId,
					cdrId: callId,
					generateError: false
				},
				success: function(data) {
					callback && callback(data.data);
				},
				error: function(data, status, globalHandler) {
					if (data && data.error === '404') {
						error && error({});
					} else {
						globalHandler(data, { generateError: true });
					}
				}
			});
		},

		listRecordingInit: function(callback) {
			var self = this;
			callback(self);
		},


		listRecordings: function(filters, callback) {
			var self = this;

			self.callApi({
				resource: 'recordings.list',
				data: {
					accountId: self.accountId,
					filters: filters
				},
				success: function(data) {
					callback && callback(data.data);
				}
			});
		},

		getRecording: function(recId, callback) {
			var self = this;

			self.callApi({
				resource: 'recordings.get',
				data: {
					accountId: self.accountId,
					recordingId: recId
				},
				success: function(data) {
					callback && callback(data.data);
				}
			});
		},

		bulkRemoveRecordings: function(recs,callback) {
			var self = this;
			$recIds = recs;
			$recIds.each(function(index) {
				self.removeRecording(index);
			});
		},

		removeRecording: function(recId, callback) {
			var self = this;

			self.callApi({
				resource: 'recordings.delete',
				data: {
					accountId: self.accountId,
					recordingId: recId
				},
				success: function(data) {
					callback && callback(data.data);
				}
			});
		}
	};

	return app;
});
