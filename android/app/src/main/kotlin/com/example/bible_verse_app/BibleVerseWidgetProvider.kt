package com.example.bible_verse_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class BibleVerseWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val verseText = widgetData.getString(
                "widget_verse_text",
                "«Ouvrez l'application pour charger votre verset du jour»"
            ) ?: "«Ouvrez l'application pour charger votre verset du jour»"
            val verseRef = widgetData.getString("widget_verse_ref", "") ?: ""

            val views = RemoteViews(context.packageName, R.layout.bible_verse_widget)
            views.setTextViewText(R.id.widget_verse_text, verseText)
            views.setTextViewText(R.id.widget_reference, verseRef)

            // Tap sur le widget → ouvre l'application
            val intent = Intent(context, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(
                context, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
