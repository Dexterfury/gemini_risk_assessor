import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/screens/assessment_details_screen.dart';
import 'package:gemini_risk_assessor/utilities/my_image_cache_manager.dart';

class ListItem extends StatelessWidget {
  const ListItem({
    super.key,
    required this.docTitle,
    required this.data,
  });

  final String docTitle;
  final AssessmentModel data;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: SizedBox(
        height: 60,
        width: 80,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CachedNetworkImage(
            imageUrl: data.images.first,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => const Center(
                child: Icon(
              Icons.error,
              color: Colors.red,
            )),
            cacheManager: MyImageCacheManager.itemsCacheManager,
          ),
        ),
      ),
      title: Text(data.title),
      subtitle: Text(
        data.summary,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      // trailing: Icon(
      //   Platform.isIOS ? Icons.arrow_forward_ios : Icons.arrow_forward,
      // ),
      onTap: () async {
        // navigate to detail page
        // display the risk assessment details screen
        PageRouteBuilder pageRouteBuilder = PageRouteBuilder(
          opaque: false,
          pageBuilder: (BuildContext context, animation, secondaryAnimation) =>
              AssessmentDetailsScreen(
            appBarTitle: docTitle,
            animation: animation,
            currentModel: data,
          ),
        );
        bool shouldSave = await Navigator.of(context).push(pageRouteBuilder);
        if (shouldSave) {
          // TODO save the risk assessment to database
        }

        // // here I want to download and open the file if its not already saved to local
        // // if its already saved to local then open it
        // final assessmentProvider = context.read<AssessmentProvider>();
        // if (!assessmentProvider.isLoading) {
        //   final isDownloaded =
        //       await assessmentProvider.isPdfDownloaded('${data.id}.pdf');
        //   if (!isDownloaded) {
        //     // Show a message that the file needs to be downloaded
        //     showSnackBar(
        //         context: context, message: 'Downloading PDF. Please wait...');
        //   }
        //   await assessmentProvider.openPdf(data.pdfUrl, '${data.id}.pdf');
        // }
        // //await assessmentProvider.deletePdf('${data.id}.pdf');
      },
    );
  }
}
